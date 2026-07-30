# ~/.bashrc: executed by bash(1) for non-login shells.

case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ── Homebrew (portable: macOS + Linux) ──
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$_brew" ]] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# ── rustup + cargo shims on PATH ──
export PATH="$HOME/.cargo/bin:$PATH"
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
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# ── SDKMAN (must stay at end of file) ──
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
