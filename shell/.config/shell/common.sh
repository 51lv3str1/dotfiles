# Shared shell env for every OS. Sourced from .zshrc/.bashrc before the
# per-OS include. (~/.cargo/bin and Homebrew live in the rc's portable blocks.)

# User-local binaries: pipx, `pip --user`, personal scripts. XDG standard,
# present on both macOS and Linux.
export PATH="$HOME/.local/bin:$PATH"
