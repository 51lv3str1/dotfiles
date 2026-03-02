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
  export PKG_CONFIG_PATH="/opt/homebrew/opt/libxml2/lib/pkgconfig"

  alias clip="pbcopy"

  alias update="brew update && brew upgrade && brew cleanup && cargo install-update -a"
else
  # Linux

  # XDG
  export XDG_DATA_DIRS="$HOME/.local/share:/usr/local/share:/usr/share"

  # Homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  alias clip="wl-copy"
  alias niriconfig="nvim ~/.config/niri/config.kdl"

  alias update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && brew upgrade && cargo install-update -a"
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

# ─── Bitwarden ────────────────────────────────────────────────
bwls() { bw list items --search "$1" | jq ".[].name"; }
bwu() { bw get username "$1" | clip; }
bwp() { bw get password "$1" | clip; }

