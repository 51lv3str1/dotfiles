return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- or "latte", "frappe", "macchiato"
      transparent_background = true,
      integrations = {
        lualine = true, -- 👈 enable lualine integration
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
