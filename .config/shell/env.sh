# Shared by bash and zsh. POSIX only. Idempotent.

# --- Platform -----------------------------------------------------------
# One place to branch on. zsh and bash both set OSTYPE, so the common case
# costs no fork; uname is only for a plain sh. Exported so subshells inherit
# it instead of probing again.
if [ -z "${DOTFILES_OS-}" ]; then
    case "${OSTYPE-}" in
        darwin*) DOTFILES_OS=Darwin ;;
        linux*)  DOTFILES_OS=Linux ;;
        *)       DOTFILES_OS=$(uname -s) ;;
    esac
    # WSL says Linux, but its clipboard and browser are the Windows ones.
    if [ "$DOTFILES_OS" = Linux ] && [ -n "${WSL_DISTRO_NAME-}" ]; then
        DOTFILES_OS=WSL
    fi
    export DOTFILES_OS
fi

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
    # No skip when already present: _path_dedupe keeps the first occurrence,
    # so prepending again is how an entry gets moved to the front.
    PATH="$1:$PATH"
}

# macOS: /etc/zprofile runs path_helper between .zshenv and .zprofile, and it
# rebuilds PATH with the system dirs first, demoting brew behind /usr/bin.
# The shellenv guard above cannot catch that -- brew is still on PATH, just
# late -- so put the prefix back in front on every pass.
if [ -n "${HOMEBREW_PREFIX-}" ]; then
    _path_prepend "$HOMEBREW_PREFIX/sbin"
    _path_prepend "$HOMEBREW_PREFIX/bin"
fi

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

# Non-interactive, non-login bash reads only this. Does not reach
# `ssh host cmd`: sshd exports nothing of the user's, so nothing sets it
# there. It does cover scripts, make and git hooks started from a session.
export BASH_ENV="$HOME/.config/shell/env.sh"

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
