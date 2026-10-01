-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("n", "<leader>ob", function()
      vim.fn.jobstart({ "xdg-open", vim.fn.expand("%:p") }, { detach = true })
    end, { buffer = true, desc = "Open HTML in browser" })
  end,
})

-- autocmds.lua — per-project HTML dev server
-- Each unique project directory gets its own port.
-- Servers are tracked by job ID so Neovim can stop them cleanly.

local servers = {} -- dir -> { port: string, job_id: number }
local BASE_PORT = 8080

-- ─────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────

--- Returns the first free port at or above `start`.
local function find_free_port(start)
  local p = start
  for _ = 1, 20 do -- give up after 20 attempts
    local result = vim.fn.system("lsof -i :" .. p .. " -t")
    if vim.trim(result) == "" then
      return tostring(p)
    end
    p = p + 1
  end
  error("Could not find a free port starting at " .. start)
end

--- True if the port still has a process listening.
local function port_alive(port)
  return vim.trim(vim.fn.system("lsof -i :" .. port .. " -t")) ~= ""
end

--- Stop and forget a server entry.
local function stop_server(dir)
  local entry = servers[dir]
  if not entry then
    return
  end
  -- jobstop sends SIGTERM; ignore errors if already dead
  pcall(vim.fn.jobstop, entry.job_id)
  servers[dir] = nil
  vim.notify("[dev-server] stopped on :" .. entry.port .. " (" .. dir .. ")", vim.log.levels.INFO)
end

-- ─────────────────────────────────────────────
-- Core: get or start a server for a directory
-- ─────────────────────────────────────────────

--- Ensures a live server exists for `dir`, then calls `cb(port)`.
local function ensure_server(dir, cb)
  local entry = servers[dir]

  -- Re-use existing server if the process is still alive
  if entry and port_alive(entry.port) then
    cb(entry.port)
    return
  end

  -- Entry exists but process died — clean up the stale record
  if entry then
    servers[dir] = nil
    vim.notify("[dev-server] previous server for " .. dir .. " died; restarting…", vim.log.levels.WARN)
  end

  -- Find a port that is not used by ANY of our existing servers or anything
  -- else on the system.
  local used_ports = {}
  for _, e in pairs(servers) do
    used_ports[e.port] = true
  end

  local port = find_free_port(BASE_PORT)
  while used_ports[port] do
    port = find_free_port(tonumber(port) + 1)
  end

  local job_id = vim.fn.jobstart({ "python3", "-m", "http.server", port }, {
    cwd = dir,
    detach = false, -- keep Neovim in charge; kills with SIGHUP on exit
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      -- Remove stale entry when the server exits for any reason
      if servers[dir] and servers[dir].port == port then
        servers[dir] = nil
        if code ~= 0 and code ~= 143 then -- 143 = SIGTERM (normal stop)
          vim.schedule(function()
            vim.notify("[dev-server] server on :" .. port .. " exited with code " .. code, vim.log.levels.WARN)
          end)
        end
      end
    end,
  })

  if job_id <= 0 then
    vim.notify("[dev-server] failed to start python3 http.server — is python3 in PATH?", vim.log.levels.ERROR)
    return
  end

  servers[dir] = { port = port, job_id = job_id }
  vim.notify("[dev-server] started on http://localhost:" .. port .. "  (" .. dir .. ")", vim.log.levels.INFO)

  -- Give python a moment to bind the socket before the browser connects
  vim.defer_fn(function()
    cb(port)
  end, 300)
end

-- ─────────────────────────────────────────────
-- Keymap: <leader>ob — open current HTML file
-- ─────────────────────────────────────────────

vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("n", "<leader>mb", function()
      local file = vim.fn.expand("%:t") -- e.g. index.html
      local dir = vim.fn.expand("%:p:h") -- absolute dir of the file

      ensure_server(dir, function(port)
        local url = "http://localhost:" .. port .. "/" .. file
        vim.fn.jobstart({ "xdg-open", url }, { detach = true })
      end)
    end, { buffer = true, desc = "Open HTML in browser via dev server" })
  end,
})

-- ─────────────────────────────────────────────
-- User commands
-- ─────────────────────────────────────────────

-- :ServerList  — show all running dev servers
vim.api.nvim_create_user_command("ServerList", function()
  if next(servers) == nil then
    vim.notify("[dev-server] no servers running", vim.log.levels.INFO)
    return
  end
  local lines = { "[dev-server] running servers:" }
  for dir, entry in pairs(servers) do
    local alive = port_alive(entry.port) and "✓" or "✗ (dead)"
    table.insert(lines, string.format("  %s  :%s  %s", alive, entry.port, dir))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "List running HTML dev servers" })

-- :ServerStop  — stop the server for the current file's directory
vim.api.nvim_create_user_command("ServerStop", function()
  local dir = vim.fn.expand("%:p:h")
  if servers[dir] then
    stop_server(dir)
  else
    vim.notify("[dev-server] no server running for " .. dir, vim.log.levels.WARN)
  end
end, { desc = "Stop dev server for current project" })

-- :ServerStopAll  — stop every server
vim.api.nvim_create_user_command("ServerStopAll", function()
  for dir in pairs(vim.deepcopy(servers)) do
    stop_server(dir)
  end
  vim.notify("[dev-server] all servers stopped", vim.log.levels.INFO)
end, { desc = "Stop all running dev servers" })

-- ─────────────────────────────────────────────
-- Cleanup on exit
-- ─────────────────────────────────────────────

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for dir in pairs(vim.deepcopy(servers)) do
      stop_server(dir)
    end
  end,
})
