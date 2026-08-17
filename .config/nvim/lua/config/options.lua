-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Inside tmux $TERM is always tmux-256color, whatever is really drawing, so
-- ask tmux what the terminal underneath is. The bare console has 16 colours,
-- where 24-bit values collapse toward blue.
local outer = vim.env.TERM
if vim.env.TMUX then
  local ok, name = pcall(vim.fn.system, { "tmux", "display", "-p", "#{client_termname}" })
  if ok then
    outer = vim.trim(name)
  end
end

vim.g.bare_console = outer == "linux"
if vim.g.bare_console then
  vim.opt.termguicolors = false
end
