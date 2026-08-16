# Shared by bash and zsh. POSIX only. Idempotent.

# --- Homebrew -----------------------------------------------------------
# Both halves can be missing independently: a session may inherit
# HOMEBREW_PREFIX without the prefix in PATH, or the reverse.
if [ -z "${HOMEBREW_PREFIX-}" ] || ! command -v brew >/dev/null 2>&1; then
    for _brew in /home/linuxbrew/.linuxbrew/bin/brew \
                 /opt/homebrew/bin/brew \
                 /usr/local/bin/brew; do
        [ -x "$_brew" ] || continue
        # The zsh variant emits fpath syntax bash cannot parse.
        if [ -n "${ZSH_VERSION-}" ]; then
            _shell=zsh
        elif [ -n "${BASH_VERSION-}" ]; then
            _shell=bash
        else
            _shell=sh
        fi
        # shellenv emits NOTHING when the prefix is already in PATH, which
        # would leave HOMEBREW_PREFIX and the completions unset. Strip PATH
        # for the call so it always emits; _path_dedupe below drops the
        # duplicate entry that creates.
        eval "$(PATH=/usr/bin:/bin "$_brew" shellenv "$_shell")"
        unset _shell
        break
    done
    unset _brew
fi

# --- PATH ---------------------------------------------------------------
_path_prepend() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
    esac
    PATH="$1:$PATH"
}

_path_prepend "$HOME/bin"
_path_prepend "$HOME/.local/bin"

# rustup is keg-only, so brew does not link its shims into the prefix.
[ -n "${HOMEBREW_PREFIX-}" ] && _path_prepend "$HOMEBREW_PREFIX/opt/rustup/bin"
_path_prepend "$HOME/.cargo/bin"

# Keep the first occurrence of each entry.
_path_dedupe() {
    _out=""
    _rest="$PATH"
    while [ -n "$_rest" ]; do
        _dir=${_rest%%:*}
        case "$_rest" in
            *:*) _rest=${_rest#*:} ;;
            *)   _rest="" ;;
        esac
        [ -n "$_dir" ] || continue
        case ":$_out:" in
            *":$_dir:"*) continue ;;
        esac
        _out="${_out:+$_out:}$_dir"
    done
    PATH="$_out"
    unset _out _rest _dir
}
_path_dedupe

unset -f _path_prepend _path_dedupe
export PATH

# --- Build flags --------------------------------------------------------
# openssl@3 is keg-only on macOS; without this, openssl-sys fails to build.
if [ -n "${HOMEBREW_PREFIX-}" ] && [ -d "$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig" ]; then
    case ":${PKG_CONFIG_PATH-}:" in
        *":$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig:"*) ;;
        *)
            PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/openssl@3/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
            export PKG_CONFIG_PATH
            ;;
    esac
fi

# --- Defaults -----------------------------------------------------------
export EDITOR="${EDITOR:-vi}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"

# Claude Code drops to 256 colors inside tmux unless this is set. Gated on
# COLORTERM: on a bare console there is no truecolor to ask for.
case "${COLORTERM-}" in
    truecolor|24bit) export CLAUDE_CODE_TMUX_TRUECOLOR=1 ;;
esac

# --- Aliases ------------------------------------------------------------
# Interactive only: scripts and `ssh host cmd` read this file too.
case $- in
    *i*)
        alias ll='ls -lh'
        alias la='ls -lAh'
        alias l='ls -CF'
        alias ..='cd ..'
        alias ...='cd ../..'
        ;;
esac

# --- Terminal image viewing ---------------------------------------------
# --symbols is not cosmetic: under TERM=tmux-256color chafa assumes Unicode
# blocks are unsafe and falls back to ASCII letters.
case $- in
    *i*)
        img() {
            chafa -f symbols -c full --symbols block+border+space \
                  -w 9 --color-space din99d "$@"
        }
        ;;
esac

# --- History ------------------------------------------------------------
# Truncating the files is not enough: the running shell keeps its own copy in
# memory and writes it back on exit. bash has `history -c` for that; zsh has
# no equivalent, so push a fresh empty history with `fc -p`.
case $- in
    *i*)
        forget() {
            : >| "$HOME/.bash_history"
            : >| "$HOME/.zsh_history"
            if [ -n "${ZSH_VERSION-}" ]; then
                fc -p "${HISTFILE:-$HOME/.zsh_history}"
            elif [ -n "${BASH_VERSION-}" ]; then
                history -c
            fi
        }
        ;;
esac

# Machine-specific, not versioned.
[ -r "$HOME/.config/shell/local.sh" ] && . "$HOME/.config/shell/local.sh"
