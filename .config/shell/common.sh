# Shared shell env for every OS.
export PATH="$HOME/.local/bin:$PATH"

# ── pkg-config: Homebrew libraries ──
if [ -n "$HOMEBREW_PREFIX" ]; then
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig:$HOMEBREW_PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

# ── Modern CLI tools (Homebrew) ──
if command -v eza >/dev/null 2>&1; then
  alias ez='eza --icons=auto --group-directories-first'
  alias ezl='eza -lh --icons=auto --group-directories-first --git'
  alias ezla='eza -lah --icons=auto --group-directories-first --git'
  alias ezt='eza --tree --level=2 --icons=auto'
fi

if command -v bat >/dev/null 2>&1; then
  alias bcat='bat --style=plain --paging=never'
fi
