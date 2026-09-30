-- Minimal Neovim config (0.11+): lazy.nvim, snacks, catppuccin, native LSP.
-- Language servers come from PATH (install via Nix), not Mason.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.clipboard = "unnamedplus"
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.completeopt = "menuone,noselect,popup"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      explorer = { enabled = true },
      picker = { enabled = true },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader><space>", function() Snacks.picker.files() end, desc = "Find files" },
    },
  },
  -- Only provides server definitions (cmd, filetypes, root markers); installs nothing.
  { "neovim/nvim-lspconfig" },
  { "olrtg/nvim-emmet", ft = { "html", "css", "javascriptreact", "typescriptreact" } },
}, {
  checker = { enabled = false },
})

-- LSP
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } } } },
})
vim.lsp.config("qmlls", { cmd = { "qmlls", "-E" } })
vim.lsp.enable({ "clangd", "lua_ls", "emmet_language_server", "qmlls" })

vim.diagnostic.config({ virtual_text = true })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
-- Built-in LSP keys: K hover, grn rename, gra code action, grr references,
-- gri implementation, Ctrl-] definition, [d / ]d diagnostics. See :help lsp-defaults
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format buffer" })

-- Your HTML dev server (lua/devserver.lua)
require("devserver")
