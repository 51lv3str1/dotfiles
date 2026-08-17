-- LazyVim ships catppuccin alongside tokyonight, so all four flavours are
-- already installed: catppuccin-{mocha,macchiato,frappe,latte}.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- Catppuccin defines no cterm colours and turns termguicolors back on
      -- as it loads, so on the console it is blue mush. `default` is the one
      -- scheme that paints only with slots 0-15, which is exactly what the
      -- tty has -- and env.sh loads Catppuccin into those slots, so this
      -- comes out in the same colours. vim.g.bare_console: config/options.
      colorscheme = vim.g.bare_console and "default" or "catppuccin-mocha",
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      integrations = {
        -- The mode badge is the most persistent colour on screen, and normal
        -- mode ships blue. Visual already held mauve, so it moves to pink
        -- rather than collide.
        lualine = {
          all = function(c)
            return {
              normal = { a = { bg = c.mauve }, b = { fg = c.mauve } },
              visual = { a = { bg = c.pink }, b = { fg = c.pink } },
              inactive = { a = { fg = c.mauve } },
            }
          end,
        },
      },

      -- Catppuccin accents its chrome with blue; everything else here --
      -- the DMS shell, tmux, the niri focus ring -- is on mauve. These are
      -- the UI groups only. Syntax keeps blue, or functions would stop
      -- being distinguishable from keywords, which are mauve already.
      --
      -- Taking the palette as an argument means this follows the flavour:
      -- switch to latte and the accent becomes its mauve, not mocha's.
      custom_highlights = function(c)
        local accent = { fg = c.mauve }
        local groups = {
          -- Floating windows and popup borders
          "FloatBorder",
          "PmenuBorder",
          "BlinkCmpDocBorder",
          "BlinkCmpMenuBorder",
          "BlinkCmpSignatureHelpBorder",
          "NoiceConfirmBorder",
          "LspInfoBorder",
          "WhichKeyBorder",
          "SnacksPickerBorder",
          "SnacksPickerInputBorder",
          "TelescopeBorder",
          "FzfLuaBorder",
          "MiniPickBorder",
          "MiniFilesBorder",
          "MiniNotifyBorder",
          "MiniClueBorder",
          "NeoTreeFloatBorder",
          -- Titles and headers, the dashboard among them
          "Title",
          "SnacksDashboardHeader",
          "SnacksDashboardTitle",
          "SnacksDashboardDesc",
          "SnacksWinBar",
          "MiniDepsTitle",
          "WhichKeyGroup",
          -- Directories in every file picker
          "Directory",
          "NeoTreeDirectoryName",
          "NeoTreeRootName",
          "MiniFilesDirectory",
          -- The matched substring while filtering
          "SnacksPickerMatch",
          "TelescopeMatching",
          "FzfLuaFzfMatch",
        }
        local hl = {}
        for _, g in ipairs(groups) do
          hl[g] = accent
        end
        return hl
      end,
    },
  },
}
