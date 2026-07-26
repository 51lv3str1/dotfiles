-- Difference from the LazyVim starter default (tokyonight): use Catppuccin
-- Mocha, so Neovim matches Alacritty, starship and tmux on this machine.
return {
  -- Catppuccin already ships as a LazyVim dependency; pin the flavour to Mocha.
  { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
  -- Make it LazyVim's active colorscheme.
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
