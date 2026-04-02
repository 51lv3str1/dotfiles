# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git dotenv)

source $ZSH/oh-my-zsh.sh

# ─── PATH ─────────────────────────────────────────────────────
export MANPATH="/usr/local/man:$MANPATH"
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:/usr/local/bin
export PATH=$HOME/.cargo/bin:$PATH

# ─── OS-specific config ───────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS

  # Homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="/opt/homebrew/opt/libxml2/bin:$PATH"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/libxml2/lib/pkgconfig"
  export LDFLAGS="-L/opt/homebrew/opt/libxml2/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/libxml2/include"

  # clipboard
  alias clip="pbcopy"

  # System
  alias update="brew update && brew upgrade && brew cleanup && cargo install-update -a"

else
  # Linux

  # XDG
  export XDG_DATA_DIRS="$HOME/.local/share:/usr/local/share:/usr/share"

  # clipboard
  alias clip="wl-copy"

  # Homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

  # System
  alias niriconfig="nvim ~/.config/niri/config.kdl"
  alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a"
  alias mimeapps="update-desktop-database ~/.local/share/applications && xdgctl"
fi

# ─── Aliases comunes ──────────────────────────────────────────
alias ls="eza --icons"
alias ll="eza -lh --icons --git"
alias la="eza -lah --icons --git"
alias lt="eza --tree --icons"
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias starshipconfig="nvim ~/.config/starship.toml"
alias alacrittyconfig="nvim ~/.config/alacritty/alacritty.toml"
alias cat="bat"
alias top="btop"
alias grep="rg"
alias cd="z"
alias lg="lazygit"
alias ld="lazydocker"
alias jira="jiratui ui"
alias tks="tmux kill-server"
alias tkss="tmux kill-session"
alias tls="tmux ls"
alias ta="tmux attach"
alias rss="eilmeldung"
alias cal_sync="vdirsyncer sync"

# ─── Shell tools ──────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

# ─── SDKMAN ───────────────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"

[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
if [ -f ".sdkmanrc" ]; then
  sdk env install
fi

# ─── NVM (lazy load) ──────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"

lazy_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() { lazy_nvm; nvm "$@"; }
node() { lazy_nvm; node "$@"; }
npm() { lazy_nvm; npm "$@"; }
npx() { lazy_nvm; npx "$@"; }

fpath+=${ZDOTDIR:-~}/.zsh_functions

search() {
  if command -v brew &>/dev/null; then
    echo "\n🍺 Homebrew:"
    results=$(brew search "$1" 2>/dev/null | grep -v "^==>")
    if [ -n "$results" ]; then
      echo "$results" | tr '\n' ' ' | xargs brew info --json 2>/dev/null | \
        jq -r '.[] | "\(.name): \(.versions.stable)"'
    else
      echo "  No package found for \"$1\""
    fi
  fi

  if command -v cargo &>/dev/null; then
    echo "\n📦 Cargo (crates.io):"
    cargo_results=$(cargo search "$1")
    if [ -n "$cargo_results" ]; then
      echo "$cargo_results"
    else
      echo "  No package found for \"$1\""
    fi
  fi

  if command -v apt-cache &>/dev/null; then
    echo "\n🐧 APT:"
    apt_results=$(apt-cache search "$1")
    if [ -n "$apt_results" ]; then
      echo "$apt_results"
    else
      echo "  No package found for \"$1\""
    fi
  fi
}

install() {
  local options=()

  if command -v brew &>/dev/null; then
    results=$(brew search "$1" 2>/dev/null | grep -v "^==>")
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] && options+=("brew: $pkg")
    done <<< "$results"
  fi

  if command -v cargo &>/dev/null; then
    results=$(cargo search "$1" 2>/dev/null | grep "^[a-z]" | awk '{print $1}' | tr -d '"')
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] && options+=("cargo: $pkg")
    done <<< "$results"
  fi

  if command -v apt-cache &>/dev/null; then
    results=$(apt-cache search "$1" 2>/dev/null | awk '{print $1}')
    while IFS= read -r pkg; do
      [[ -n "$pkg" ]] && options+=("apt: $pkg")
    done <<< "$results"
  fi

  if [ ${#options[@]} -eq 0 ]; then
    echo "No packages found for \"$1\""
    return 1
  fi

  local selected
  selected=$(printf '%s\n' "${options[@]}" | fzf --prompt="Install > " --height=40% --border)

  [[ -z "$selected" ]] && return 0

  local manager pkg
  manager=$(echo "$selected" | cut -d: -f1)
  pkg=$(echo "$selected" | cut -d: -f2 | xargs)

  case "$manager" in
    brew)  brew install "$pkg" ;;
    cargo) cargo install "$pkg" ;;
    apt)   sudo apt install "$pkg" ;;
  esac
}
