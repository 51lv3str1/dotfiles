# Linux-specific shell env/aliases/functions. Sourced from .zshrc/.bashrc by $OSTYPE.

# update — full system upgrade: apt (Debian), Homebrew, and Cargo binaries.
# `cargo install-update -a` needs the `cargo-update` crate installed.
alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a"

# clip — copy stdin to the clipboard, picking the backend by graphic session:
# Wayland -> wl-copy, X11/Xorg -> xclip (fallback xsel). Decided at call time
# so it follows the session you're actually in. Usage: `echo hi | clip`.
clip() {
  if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif [ -n "$DISPLAY" ] && command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    printf 'clip: no clipboard tool for this session (need wl-clipboard on Wayland, or xclip/xsel on X11)\n' >&2
    return 1
  fi
}
