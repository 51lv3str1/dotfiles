# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a **Stow package** that mirrors the layout under
`$HOME`; stowing a package symlinks its files into place. Written to be
**cross-platform** — the same files work on macOS (Apple Silicon & Intel) and
Linux, and degrade cleanly on Git Bash / MSYS where a tool isn't present.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/) — `brew install stow`

## Install on a new machine

```sh
brew install stow
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
stow zsh bash git        # or: stow */   (stows every package)
```

Stow refuses to overwrite an existing **real** file (only symlinks are safe).
If a target already exists, move it into the package first, then stow:

```sh
mkdir -p ~/dotfiles/<pkg>
mv ~/.<file> ~/dotfiles/<pkg>/.<file>
cd ~/dotfiles && stow <pkg>
```

To unlink a package: `stow -D <pkg>`. To re-link after adding files: `stow -R <pkg>`.

## Packages

| Package | Links to | Contents |
|---|---|---|
| `zsh`   | `~/.zshrc`         | Oh My Zsh setup + the portable env blocks below; sources the `shell` includes |
| `bash`  | `~/.bashrc`        | Same portable env blocks as zsh (fallback shell); sources the `shell` includes |
| `git`   | `~/.gitconfig`     | User identity (name + email) |
| `shell` | `~/.config/shell/` | Cross-shell includes: `common.sh` (shared env) + `linux.sh` / `macos.sh` (per-OS env, aliases, functions), sourced by `$OSTYPE` |
| `alacritty` | `~/.config/alacritty/` | Alacritty config: `alacritty.toml` (DepartureMono Nerd Font, cursor/mouse/bell tweaks, copy/paste/font/scroll keybindings) which imports `catppuccin-mocha.toml` (official Catppuccin Mocha theme) |
| `starship` | `~/.config/starship.toml` | [Starship](https://starship.rs) prompt config (Catppuccin Mocha palette). Init lines live in `.zshrc`/`.bashrc`; needs a Nerd Font in the terminal for its glyphs |
| `nvim` | `~/.config/nvim/` | Neovim config based on the [LazyVim](https://www.lazyvim.org) starter (lazy.nvim). Only change from upstream: `lua/plugins/colorscheme.lua` overrides the default theme with Catppuccin Mocha. Plugins self-install on first launch (needs git + network); a C compiler is needed for treesitter parsers |
| `tmux` | `~/.tmux.conf` | tmux config, self-contained (no plugin manager): true-color, mouse, 1-based windows, `prefix + r` reload, `\|`/`-` splits, and a hand-written Catppuccin Mocha statusline matching Alacritty/starship |
| `claude` | `~/.claude/CLAUDE.md` | Global Claude Code instructions, shared across machines. Stows **only** `CLAUDE.md` — the rest of `~/.claude` (settings, projects, memory) is machine-specific and stays untracked |

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
