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
| `zsh`  | `~/.zshrc`    | Oh My Zsh setup + the portable env blocks below |
| `bash` | `~/.bashrc`   | Same portable env blocks as zsh (fallback shell) |
| `git`  | `~/.gitconfig`| User identity (name + email) |

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
