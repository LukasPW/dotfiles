-- Per-project HTML dev server (moved from LazyVim's autocmds.lua, unchanged logic).
-- Needs python3 and lsof on PATH.
-- <leader>ob : open current HTML file directly in browser
-- <leader>mb : open current HTML file via a per-directory python http.server
-- :ServerList / :ServerStop / :ServerStopAll

local servers = {} -- dir -> { port: string, job_id: number }
local BASE_PORT = 8080

local function find_free_port(start)
  local p = start
  for _ = 1, 20 do
    if vim.trim(vim.fn.system("lsof -i :" .. p .. " -t")) == "" then
      return tostring(p)
    end
    p = p + 1
  end
  error("Could not find a free port starting at " .. start)
end

local function port_alive(port)
  return vim.trim(vim.fn.system("lsof -i :" .. port .. " -t")) ~= ""
end

local function stop_server(dir)
  local entry = servers[dir]
  if not entry then
    return
  end
  pcall(vim.fn.jobstop, entry.job_id)
  servers[dir] = nil
  vim.notify("[dev-server] stopped on :" .. entry.port .. " (" .. dir .. ")", vim.log.levels.INFO)
end

local function ensure_server(dir, cb)
  local entry = servers[dir]
  if entry and port_alive(entry.port) then
    cb(entry.port)
    return
  end
  if entry then
    servers[dir] = nil
    vim.notify("[dev-server] previous server for " .. dir .. " died; restarting…", vim.log.levels.WARN)
  end

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
    detach = false,
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if servers[dir] and servers[dir].port == port then
        servers[dir] = nil
        if code ~= 0 and code ~= 143 then
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
  vim.defer_fn(function()
    cb(port)
  end, 300)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("n", "<leader>ob", function()
      vim.fn.jobstart({ "xdg-open", vim.fn.expand("%:p") }, { detach = true })
    end, { buffer = true, desc = "Open HTML in browser" })

    vim.keymap.set("n", "<leader>mb", function()
      local file = vim.fn.expand("%:t")
      local dir = vim.fn.expand("%:p:h")
      ensure_server(dir, function(port)
        vim.fn.jobstart({ "xdg-open", "http://localhost:" .. port .. "/" .. file }, { detach = true })
      end)
    end, { buffer = true, desc = "Open HTML in browser via dev server" })
  end,
})

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

vim.api.nvim_create_user_command("ServerStop", function()
  local dir = vim.fn.expand("%:p:h")
  if servers[dir] then
    stop_server(dir)
  else
    vim.notify("[dev-server] no server running for " .. dir, vim.log.levels.WARN)
  end
end, { desc = "Stop dev server for current project" })

vim.api.nvim_create_user_command("ServerStopAll", function()
  for dir in pairs(vim.deepcopy(servers)) do
    stop_server(dir)
  end
  vim.notify("[dev-server] all servers stopped", vim.log.levels.INFO)
end, { desc = "Stop all running dev servers" })

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for dir in pairs(vim.deepcopy(servers)) do
      stop_server(dir)
    end
  end,
})
