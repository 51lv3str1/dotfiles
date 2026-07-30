# macOS-specific shell env/aliases/functions.
alias clip="pbcopy"

# ── libxml2 from Homebrew ──
if [ -d "$HOMEBREW_PREFIX/opt/libxml2" ]; then
  export PATH="$HOMEBREW_PREFIX/opt/libxml2/bin:$PATH"
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/libxml2/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib${LDFLAGS:+ $LDFLAGS}"
  export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include${CPPFLAGS:+ $CPPFLAGS}"
fi
