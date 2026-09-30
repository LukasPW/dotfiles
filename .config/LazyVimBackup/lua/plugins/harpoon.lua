return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local telescope = require("telescope")
    telescope.load_extension("harpoon")

    local map = vim.keymap.set
    local list = function()
      return harpoon:list()
    end

    map("n", "<leader>a", function() list():add() end)
    map("n", "<leader>q", function() harpoon.ui:toggle_quick_menu(list()) end)

    map("n", "<leader>1", function() list():select(1) end)
    map("n", "<leader>2", function() list():select(2) end)
    map("n", "<leader>3", function() list():select(3) end)
    map("n", "<leader>4", function() list():select(4) end)

    map("n", "<leader>hn", function() list():next() end)
    map("n", "<leader>hp", function() list():prev() end)

    map("n", "<leader>hf", function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local items = list().items

      pickers.new({}, {
        prompt_title = "Harpoon",
        finder = finders.new_table({
          results = items,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.value,
              ordinal = entry.value,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            list():select(selection.index)
          end)
          return true
        end,
      }):find()
    end)
  end,
}
