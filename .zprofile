# Login shells. env.sh is idempotent, so .zshenv sourcing it too is harmless.

[ -r "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
