# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
The repository root mirrors the layout under `$HOME`, so the repo **is** a single
Stow package: `stow .` symlinks everything into place at once (all-or-nothing).
Written to be **cross-platform** — the same files work on macOS (Apple Silicon &
Intel) and Linux, and degrade cleanly on Git Bash / MSYS where a tool isn't
present.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/) — `brew install stow`

## Install on a new machine

```sh
brew install stow
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
stow --no-folding .
```

`stow .` targets `$HOME` (Stow's default target is the parent of the stow
directory, and the repo lives at `~/dotfiles`). Stow's built-in ignore list
skips `.git/`, the root `README.md`, and `LICENSE` so they are never linked.

`--no-folding` makes Stow link **every file individually** instead of symlinking
whole directories. This keeps real directories real, so:

- shared config dirs (e.g. `~/.config/gtk-3.0`, which also holds a non-tracked
  `bookmarks`) keep their own files, and
- tools that generate runtime state next to their config (DMS, nvim) write those
  new files into `$HOME`, not into the repo.

Stow refuses to overwrite an existing **real** file (only symlinks are safe).
If a target already exists, move it into the repo (mirroring its `$HOME` path)
first, then re-stow:

```sh
mkdir -p ~/dotfiles/.config/<app>
mv ~/.config/<app>/<file> ~/dotfiles/.config/<app>/<file>
cd ~/dotfiles && stow -R --no-folding .
```

To unlink everything: `stow -D .`. To re-link after adding files: `stow -R --no-folding .`.

> **Trade-off — all-or-nothing.** With a single package there is no selective
> install: `stow .` links *every* config, so on a minimal or macOS-only machine
> you also link the Linux/desktop bits (niri, DankMaterialShell). That is the
> intended simplicity of this layout.

## What's inside

| Config | Path under `$HOME` | Notes |
|---|---|---|
| zsh | `~/.zshrc` | Oh My Zsh setup + the portable env blocks below; sources the `shell` includes |
| zshenv | `~/.zshenv` | Sourced for ALL zsh invocations (incl. non-interactive scripts): puts `~/.cargo/bin` on PATH so tools find cargo binaries. Sources rustup's `~/.cargo/env` when present, else guarded fallback |
| bash | `~/.bashrc` | Same portable env blocks as zsh (fallback shell); sources the `shell` includes |
| git | `~/.gitconfig` | User identity (name + email) + git-lfs filter |
| shell | `~/.config/shell/` | Cross-shell includes: `common.sh` (shared env) + `linux.sh` / `macos.sh` (per-OS env, aliases, functions), sourced by `$OSTYPE` |
| alacritty | `~/.config/alacritty/` | `alacritty.toml` (DepartureMono Nerd Font, cursor/mouse/bell tweaks, copy/paste/font/scroll keybindings) importing `catppuccin-mocha.toml` (official Catppuccin Mocha theme) |
| starship | `~/.config/starship.toml` | [Starship](https://starship.rs) prompt (Catppuccin Mocha). Init lines live in `.zshrc`/`.bashrc`; needs a Nerd Font for its glyphs |
| nvim | `~/.config/nvim/` | Neovim config from the [LazyVim](https://www.lazyvim.org) starter (lazy.nvim). Only change from upstream: `lua/plugins/colorscheme.lua` sets Catppuccin Mocha. Plugins self-install on first launch (needs git + network); treesitter parsers need a C compiler |
| tmux | `~/.tmux.conf` | Self-contained (no plugin manager): true-color, mouse, 1-based windows, `prefix + r` reload, `\|`/`-` splits, hand-written Catppuccin Mocha statusline |
| claude | `~/.claude/CLAUDE.md` | Global Claude Code instructions. Only `CLAUDE.md` is tracked — the rest of `~/.claude` (settings, projects, memory) is machine-specific and stays untracked |
| dank | `~/.config/DankMaterialShell/`, `~/.config/gtk-{3,4}.0/dank-colors.css`, `~/.local/share/color-schemes/DankMatugen*.colors` | [DankMaterialShell](https://danklinux.com) (DMS, a Quickshell config running on the `dms`/`quickshell` system binaries — there is no separate user Quickshell config). Tracks the hand-made `settings.json` (bar/widget layout) plus the Matugen-**generated** theme files (`firefox.css`, GTK color CSS, KDE color schemes). Runtime state (`.firstlaunch`, `.changelog-1.5`, `~/.local/state/DankMaterialShell`, `dankcal.db`) is **not** tracked |
| niri | `~/.config/niri/` | [niri](https://github.com/YaLTeR/niri) compositor config: `config.kdl`, the DMS-generated `dms/*.kdl` (binds, colors, layout, outputs, …), and `custom-overrides.kdl` — hand-made overrides included **last** so they win over DMS (niri includes are positional; e.g. `gaps 10`) without editing the auto-generated files |

## Cross-platform env blocks (in `.zshrc` and `.bashrc`)

These are written once, identically, in both shells:

- **Homebrew** — sources `brew shellenv` from whichever prefix exists
  (`/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew`), so it works on
  macOS arm64/x86_64 and Linux, and is a no-op where brew isn't installed.
- **rustup + cargo** — always adds `~/.cargo/bin` (where `cargo install` drops
  binaries on every OS); adds the keg-only `rustup` bin only when brew provides
  it.
- **ssh-agent socket** — sets `SSH_AUTH_SOCK` to the systemd user socket
  **only on Linux and only when that socket exists**. macOS uses launchd's own
  agent; other platforms keep their default.

## Not tracked here (installed separately)

- **Oh My Zsh** (`~/.oh-my-zsh`) — install via its own bootstrap; `.zshrc`
  expects it at that path.
- Anything containing secrets.

## Notes

- `~/.gitconfig` carries the commit identity (name + e-mail). Keep the repo's
  visibility in mind before adding anything sensitive.
- The `dank` theme files and `niri/dms/*.kdl` are **regenerated by DMS/Matugen**
  (on wallpaper/theme change or DMS update). Most tools rewrite in place, so the
  changes flow through the symlink into the repo; but if one replaces a file
  atomically it will clobber the symlink with a real file — re-stow with
  `cd ~/dotfiles && stow -R --no-folding .` to restore the links, then commit the
  regenerated content.
- Put niri tweaks that would collide with DMS-generated files in
  `~/.config/niri/custom-overrides.kdl` (included last, so it wins and survives
  DMS regeneration).
