local M = {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "ibl"
  ---@type ibl.config
  opts = {},
  config = function()
    local highlight = { "iblHighlighted" }
    local hooks = require "ibl.hooks"
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "iblHighlighted", { fg = "#2c313a" })
    end)
    require("ibl").setup {
      indent = {
        highlight = highlight,
        char = '│'
      },
      scope = {
        enabled = false
      }
    }
  end
}

return M
