# Sourced by zsh for EVERY invocation (login, interactive, and non-interactive
# scripts) — unlike .zshrc, which only runs for interactive shells. Put here the
# PATH bits that non-interactive tools need.
#
# Mirrors the repo's .zshenv (`. "$HOME/.cargo/env"`), but guarded: rustup's
# ~/.cargo/env is not present on every machine (cargo can be installed without
# it), so fall back to prepending ~/.cargo/bin when the file is absent. The
# case-guard avoids duplicating the entry when shells nest.
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
elif [ -d "$HOME/.cargo/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.cargo/bin:"*) ;;
    *) export PATH="$HOME/.cargo/bin:$PATH" ;;
  esac
fi
