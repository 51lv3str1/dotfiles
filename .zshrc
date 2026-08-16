# Interactive zsh. Anything bash needs too goes in ~/.config/shell/env.sh.

[ -r "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"

# --- History ------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # leading space keeps a command out of history
setopt HIST_VERIFY            # expand !! instead of running it
setopt EXTENDED_HISTORY

# --- Navigation ---------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
unsetopt BEEP

# --- Completion ---------------------------------------------------------
# After env.sh: brew's shellenv is what puts its site-functions on fpath.
autoload -Uz compinit
_zcompcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[ -d "$_zcompcache" ] || mkdir -p "$_zcompcache"
compinit -d "$_zcompcache/zcompdump"
unset _zcompcache

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# --- Keys ---------------------------------------------------------------
bindkey -e

# Up/Down walk only history entries matching what is typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# terminfo, not hardcoded escapes: those differ per terminal and over ssh.
[[ -n ${terminfo[khome]} ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kend]}  ]] && bindkey "${terminfo[kend]}"  end-of-line
[[ -n ${terminfo[kdch1]} ]] && bindkey "${terminfo[kdch1]}" delete-char

# --- Prompt -------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '
fi

# --- fzf -----------------------------------------------------------------
# C-r, C-t and M-c. Ahead of local.zsh so that file can still rebind them.
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Machine-specific, not versioned. Before the plugins so it can bind keys.
[ -r "$HOME/.config/shell/local.zsh" ] && . "$HOME/.config/shell/local.zsh"

# --- Plugins ------------------------------------------------------------
# brew where there is one, the distro's own share/ otherwise: apt uses
# /usr/share, Arch nests them under zsh/plugins.
_load_plugin() {
    local dir
    for dir in "${HOMEBREW_PREFIX-}/share" /usr/share /usr/local/share \
               /usr/share/zsh/plugins; do
        [ -r "$dir/$1/$1.zsh" ] || continue
        source "$dir/$1/$1.zsh"
        return 0
    done
    return 1
}

_load_plugin zsh-autosuggestions
# Keep last: it wraps the line editor and must see every binding above.
_load_plugin zsh-syntax-highlighting
unset -f _load_plugin
