return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        qmlls = {
          cmd = { "qmlls", "-E" },
          filetypes = { "qml", "qmljs" },
          mason = false,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "qmljs" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        qml = { "qmlformat" },
      },
      formatters = {
        qmlformat = {
          command = "qmlformat",
          args = { "-i", "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
}
