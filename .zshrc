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

  alias clip="pbcopy"

  alias update="brew update && brew upgrade && brew cleanup && cargo install-update -a"
else
  # Linux

  # XDG
  export XDG_DATA_DIRS="$HOME/.local/share:/usr/local/share:/usr/share"

  # Homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

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
alias cal_sync="vdirsyncer sync"

alias toronja="devopen ~/GitHub/Allaria+/toronja"

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

# Unlock vault & persist session
bwul() {
  export BW_SESSION="$(bw unlock --raw)"
  echo "🔓 Vault unlocked"
}

# Auto-unlock if session missing
_bw_check() {
  if [[ -z "$BW_SESSION" ]]; then
    echo "⚠ Vault locked. Unlocking..." >&2
    bwul
  fi
}

# List items matching search
bwls() {
  _bw_check
  bw list items --search "$1" | jq -r '.[].name'
}

# Get username → clipboard
bwu() {
  _bw_check
  bw get username "$1" | clip && echo "📋 Username copied: $1"
}

# Get password → clipboard
bwp() {
  _bw_check
  bw get password "$1" | clip && echo "📋 Password copied: $1"
}

# Get TOTP code → clipboard
bwotp() {
  _bw_check
  bw get totp "$1" | clip && echo "📋 TOTP copied: $1"
}

# Get custom field value
bwf() {
  _bw_check
  bw get item "$1" | jq -r '.fields[] | select(.name=="'"$2"'") | .value'
}

# Get custom field → clipboard
bwfc() {
  _bw_check
  bw get item "$1" | jq -r '.fields[] | select(.name=="'"$2"'") | .value' | clip && echo "📋 Field '$2' copied: $1"
}

# Get notes → clipboard
bwn() {
  _bw_check
  bw get notes "$1" | clip && echo "📋 Notes copied: $1"
}

# Show all fields for an item
bwshow() {
  _bw_check
  bw get item "$1" | jq '{
    name: .name,
    username: .login.username,
    uris: [.login.uris[]?.uri],
    fields: .fields
  }'
}

# List all custom field names for an item
bwfields() {
  _bw_check
  bw get item "$1" | jq -r '.fields[]? | .name'
}

# Open item URI in browser (requires xdg-open / open / start)
bwopen() {
  _bw_check
  local uri
  uri=$(bw get item "$1" | jq -r '.login.uris[0].uri')
  [[ -n "$uri" ]] && xdg-open "$uri" 2>/dev/null || open "$uri" 2>/dev/null || start "$uri"
}

# Lock vault
bwl() {
  bw lock
  unset BW_SESSION
  echo "🔒 Vault locked"
}

# Sync vault
bwsync() {
  _bw_check
  bw sync && echo "🔄 Vault synced"
}

# Inserta un header de 2 filas encima del pane dado.
# Uso: _pane_header <pane_id>
# Devuelve en stdout el pane_id del header creado.
_pane_header() {
  local target=$1
  tmux split-window -v -b -l 2 -t "$target" -P -F '#{pane_id}'
}

devopen() {
  local SESSION="dev-$(date +%s)"
  local P="/tmp/devopen-${SESSION}"

  # Pane layout:
  #   ┌─────────────────┬────────┐
  #   │                 │        │
  #   │   pane 0        │ pane 3 │
  #   │                 │        │
  #   ├─────────────────┼────────┤
  #   │   pane 1        │ pane 4 │  ← headers (2 filas, BAR=2)
  #   ├─────────────────┼────────┤
  #   │   pane 2        │ pane 5 │
  #   └─────────────────┴────────┘
  #
  # Construcción por pane_id:
  #   new-session          → %0 (full)
  #   split %0 -h -p25     → %0=left, %1=right
  #   split %0 -v          → %0=top-left(pane0), %2=bot-left(pane2)
  #   _pane_header %2      → %3=header-left(pane1), %2=bot-left(pane2)
  #   split %1 -v          → %1=top-right(pane3), %4=bot-right(pane5)
  #   _pane_header %4      → %5=header-right(pane4), %4=bot-right(pane5)

  tmux new-session -d -s "$SESSION" -x "$(tput cols)" -y "$(tput lines)"

  local ID0 ID1 ID2 ID3 ID4 ID5

  # columna izquierda
  ID0=$(tmux display-message -p -t "$SESSION:0.0" '#{pane_id}')
  ID1=$(tmux split-window -h -p 25 -t "$ID0" -P -F '#{pane_id}')   # derecha temporal
  ID2=$(tmux split-window -v    -t "$ID0" -P -F '#{pane_id}')       # bot-left = pane 2
  local HDR_L=$(_pane_header "$ID2")                                 # header sobre pane 2 = pane 1

  # columna derecha
  ID4=$(tmux split-window -v    -t "$ID1" -P -F '#{pane_id}')       # bot-right = pane 5
  local HDR_R=$(_pane_header "$ID4")                                 # header sobre pane 5 = pane 4

  # mapeo final a índices para layout.sh
  # en este punto el orden visual de arriba a abajo, izq a der es:
  # ID0=pane0, HDR_L=pane1, ID2=pane2, ID1=pane3, HDR_R=pane4, ID4=pane5

  # layout.sh — pure resize
  # Args: SESSION  P2_H
  #   P2_H = height of pane 2 and pane 5 (must match for alignment)
  #   BAR  = 2 rows (pane 1 and pane 4)
  # Derived:
  #   P0_H = P3_H = H - BAR - P2_H
  cat > "${P}-layout.sh" << LAYOUT
#!/bin/zsh
SESSION=\$1
P2_H=\$2
BAR=2
H=\$(tmux display-message -p -t "\$SESSION" "#{window_height}" 2>/dev/null)
[[ -z "\$H" || \$H -lt 10 ]] && exit 1
(( TOP_H = H - BAR - P2_H ))
(( TOP_H < 1 )) && TOP_H=1
tmux resize-pane -t "$ID0"    -y \$TOP_H 2>/dev/null  # pane 0
tmux resize-pane -t "$HDR_L"  -y \$BAR   2>/dev/null  # pane 1
tmux resize-pane -t "$ID2"    -y \$P2_H  2>/dev/null  # pane 2
tmux resize-pane -t "$ID1"    -y \$TOP_H 2>/dev/null  # pane 3
tmux resize-pane -t "$HDR_R"  -y \$BAR   2>/dev/null  # pane 4
tmux resize-pane -t "$ID4"    -y \$P2_H  2>/dev/null  # pane 5
LAYOUT
  chmod +x "${P}-layout.sh"

  local INIT_H=$(tput lines)
  local INIT_P2_H=$(( INIT_H / 4 ))
  (( INIT_P2_H < 4 )) && INIT_P2_H=4

  tmux set-hook -t "$SESSION" after-select-window \
    "run-shell '${P}-layout.sh $SESSION $INIT_P2_H && tmux set-hook -t $SESSION -u after-select-window'"

  tmux select-window -t "$SESSION:0"
  tmux select-pane   -t "$ID0"
  tmux attach        -t "$SESSION"
}

devclose() {
  local SESSION
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  [[ -z "$SESSION" ]] && { echo "not in a tmux session"; return 1; }
  rm -f /tmp/devopen-${SESSION}-*
  tmux kill-session -t "$SESSION"
}
