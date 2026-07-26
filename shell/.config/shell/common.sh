# Shared shell env for every OS. Sourced from .zshrc/.bashrc before the
# per-OS include. (~/.cargo/bin and Homebrew live in the rc's portable blocks.)

# User-local binaries: pipx, `pip --user`, personal scripts. XDG standard,
# present on both macOS and Linux.
export PATH="$HOME/.local/bin:$PATH"

# ── Modern CLI tools (Homebrew) ──────────────────────────────────────────────
# Extra aliases under their OWN names — the native `ls`/`cat` are left untouched
# on purpose, so scripts and tools that rely on the originals keep working.
# Each block is guarded by `command -v`, so the rc degrades cleanly on a machine
# where the tool isn't installed.

# eza — a modern `ls`. `--icons=auto` only draws glyphs on a terminal (needs a
# Nerd Font); `--git` shows VCS status when inside a repo.
if command -v eza >/dev/null 2>&1; then
  alias ez='eza --icons=auto --group-directories-first'            # plain listing
  alias ezl='eza -lh --icons=auto --group-directories-first --git' # long
  alias ezla='eza -lah --icons=auto --group-directories-first --git' # long + hidden
  alias ezt='eza --tree --level=2 --icons=auto'                    # tree, 2 levels
fi

# bat — a `cat` with syntax highlighting. Use `bcat` for a quick, no-pager view.
if command -v bat >/dev/null 2>&1; then
  alias bcat='bat --style=plain --paging=never'
fi
