# Shared shell env for every OS. Sourced from .zshrc/.bashrc before the
# per-OS include. (~/.cargo/bin and Homebrew live in the rc's portable blocks.)

# User-local binaries: pipx, `pip --user`, personal scripts. XDG standard,
# present on both macOS and Linux.
export PATH="$HOME/.local/bin:$PATH"

# ── pkg-config: Homebrew libraries ───────────────────────────────────────────
# Rust `-sys` crates (openssl-sys, libgit2-sys, …) and other native builds find
# libraries via pkg-config. `brew shellenv` does NOT set PKG_CONFIG_PATH, and
# keg-only formulae like openssl@3 keep their `.pc` under opt/, not the shared
# lib/pkgconfig — so `cargo install`/`cargo install-update -a` fail with
# "openssl was not found". Add both paths. Guarded on $HOMEBREW_PREFIX (set by
# brew shellenv in the rc), so it is a no-op where brew isn't installed.
if [ -n "$HOMEBREW_PREFIX" ]; then
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig:$HOMEBREW_PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

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
