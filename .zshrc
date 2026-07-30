export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git dotenv)
source $ZSH/oh-my-zsh.sh

# ── Homebrew (portable: macOS + Linux) ──
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$_brew" ]] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# ── rustup opt/bin on PATH (cargo/bin comes from .zshenv) ──
[[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]] \
  && export PATH="$HOMEBREW_PREFIX/opt/rustup/bin:$PATH"

# ── ssh-agent socket (Linux/systemd) ──
[[ "$OSTYPE" == linux* && -S "${XDG_RUNTIME_DIR}/openssh_agent" ]] \
  && export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/openssh_agent"

# ── Shell includes: shared + per-OS ──
[[ -r "$HOME/.config/shell/common.sh" ]] && source "$HOME/.config/shell/common.sh"
case "$OSTYPE" in
  darwin*) _os_rc="$HOME/.config/shell/macos.sh" ;;
  linux*)  _os_rc="$HOME/.config/shell/linux.sh" ;;
esac
[[ -n "$_os_rc" && -r "$_os_rc" ]] && source "$_os_rc"
unset _os_rc

# ── starship prompt ──
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ── SDKMAN (must stay at end of file) ──
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
