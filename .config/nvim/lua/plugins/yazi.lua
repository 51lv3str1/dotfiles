return {
  "mikavilpas/yazi.nvim",
  keys = {
    { "<leader>yy", "<cmd>Yazi<cr>", desc = "Open Yazi in Neovim" },
  },
  opts = {
    -- optional settings
    floating_window = true, -- open Yazi in a floating window
    yazi_floating_window_winblend = 0,
  },
}
