# Linux-specific shell env/aliases/functions.
alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a"

# clip — copy stdin to the clipboard (Wayland/X11).
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
