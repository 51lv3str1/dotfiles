# macOS-specific shell env/aliases/functions. Sourced from .zshrc/.bashrc by $OSTYPE.

# clip — copy stdin to the clipboard. Usage: `echo hi | clip`.
alias clip="pbcopy"

# libxml2 from Homebrew: the macOS system libxml2 isn't pkg-config-visible, so
# builds that link against a modern libxml2 need these. Uses $HOMEBREW_PREFIX
# (set by the rc's Homebrew block) so it works on both Apple Silicon and Intel.
# Append-safe; drop this whole block if you don't build against libxml2.
if [ -d "$HOMEBREW_PREFIX/opt/libxml2" ]; then
  export PATH="$HOMEBREW_PREFIX/opt/libxml2/bin:$PATH"
  export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/libxml2/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib${LDFLAGS:+ $LDFLAGS}"
  export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include${CPPFLAGS:+ $CPPFLAGS}"
fi
