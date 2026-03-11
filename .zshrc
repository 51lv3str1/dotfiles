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

# =============================================================================
# now — compact calendar dashboard (today's events via khal)
# =============================================================================
now() {
  local ESC=$'\033'
  local reset="${ESC}[0m"   bold="${ESC}[1m"    dim="${ESC}[2m"
  local italic="${ESC}[3m"  gray="${ESC}[38;5;245m"
  local muted="${ESC}[38;5;240m"  white="${ESC}[97m"

  local -A cal_color=(
    [google]="${ESC}[38;5;75m"   [familia]="${ESC}[38;5;213m"
    [festivos]="${ESC}[38;5;120m" [daruma]="${ESC}[38;5;215m"
    [allaria]="${ESC}[38;5;159m"
  )
  local -A cal_icon=(
    [google]="󰊫" [familia]="󰉌" [festivos]="󰃦"
    [daruma]="󰃯" [allaria]="󰃯"
  )

  local now_int=$(date "+%H%M")
  local raw_events
  raw_events=$(khal list today --format "{start-time}|{end-time}|{title}|{calendar}" 2>/dev/null)

  if [[ -z "$raw_events" ]]; then
    printf "  ${muted}${italic}no events today${reset}\n\n"; return
  fi

  local -A seen
  local printed=0
  while IFS='|' read -r start end title calendar; do
    [[ "$start" =~ ^(Today|Tomorrow|Mon|Tue|Wed|Thu|Fri|Sat|Sun|Lun|Mar|Mie|Jue|Vie|Sab|Dom) ]] && continue
    [[ -z "$title" ]] && continue
    local key="${start}|${title}"
    [[ -n "${seen[$key]}" ]] && continue
    seen[$key]=1

    local color="${cal_color[$calendar]:-$white}"
    local icon="${cal_icon[$calendar]:-󰃯}"

    if [[ -z "$start" ]]; then
      printf " %s%s${reset} ${gray}%s${reset} ${dim}all day${reset} ${bold}${white}%s${reset}\n" \
        "$color" "$icon" "${calendar:-?}" "$title"
    else
      local start_int=${start//:/}  end_int=${end//:/}
      local ts="" tt="$white"
      (( start_int < now_int )) && ts="$dim" tt="$dim"
      (( start_int <= now_int && now_int <= end_int )) && ts="" tt="$white"
      printf " %s%s${reset} ${gray}%s${reset} %s%s${bold}%s${reset}%s/%s${reset} %s%s${reset}\n" \
        "$color" "$icon" "${calendar:-?}" \
        "$ts" "$color" "$start" "$ts" "$end" "$tt" "$title"
    fi
    (( printed++ ))
  done <<< "$raw_events"

  [[ $printed -eq 0 ]] && printf " ${muted}${italic}no events today${reset}\n"
  printf "\n"
}

# =============================================================================
# devopen / devclose — tmux workspace with virtual tab system
# =============================================================================
#
# LAYOUT  (window 0 pane indices)
#
#   ┌─────────────────────┬──────────┐
#   │                     │  rbar  3 │  right tab-bar     (2 rows, fixed)
#   │       nvim  0       ├──────────┤
#   │                     │ rcont  4 │  right content     (claude/lazygit/lazydocker)
#   ├─────────────────────┼──────────┤
#   │  bbar  1            │  dbar  5 │  dash tab-bar      (2 rows, fixed)
#   ├─────────────────────┼──────────┤
#   │  bcont 2            │ dcont  6 │  dash content      (now loop, starts collapsed)
#   └─────────────────────┴──────────┘
#
# PANE GROUPS
#   Left column:      nvim(0) · bbar(1) · bcont(2)   — one vertical group
#   Right top group:  rbar(3) · rcont(4)
#   Right bot group:  dbar(5) · dcont(6)
#   rcont and dbar share a border; the two right groups are independent.
#
# RESIZE RULE  (tmux invariant encoded in every _do_resize call)
#   -y 9999 on pane X expands it and IGNORES sizes previously set on neighbours.
#   Therefore: always run 9999 FIRST, then carve fixed bars AFTER.
#
# TAB SYSTEM
#   window 1 (tabs-right)  — shelf for inactive right tabs
#   window 2 (tabs-bottom) — shelf for inactive bottom tabs
#   MAP  "-:0:1"  → tab0=active, tab1=shelf-slot-0, tab2=shelf-slot-1
#
# KEY BINDINGS
#   prefix+T   cycle tab (context-aware)
#   prefix+N   new tab with optional command
#   prefix+X   kill current tab
#   prefix+C   collapse / uncollapse (context-aware)
#   prefix+G   fzf jump picker
#   prefix+D   fzf kill picker
#   h / l / ← / →  prev/next tab (bar panes 1 and 3 only)
#   Alt+1..9   jump to tab N (context-aware)
#
# DEPENDENCIES: nvim, claude, lazygit, lazydocker, fzf, khal, vdirsyncer
# =============================================================================

devopen() {
  # ---------------------------------------------------------------------------
  # Resolve target path and session name
  # ---------------------------------------------------------------------------
  local FILE="${1:-.}"
  local DIR
  if [[ -d "$FILE" ]]; then
    DIR=$(realpath "$FILE"); FILE="."
  else
    DIR=$(realpath "$(dirname "$FILE")")
  fi
  local SESSION="${NAME:=$(basename "${1:-.}")-$(date +%s)}"

  # ---------------------------------------------------------------------------
  # Dependency check
  # ---------------------------------------------------------------------------
  local dep
  for dep in nvim claude lazygit lazydocker fzf khal vdirsyncer; do
    command -v "$dep" &>/dev/null || { echo "devopen: missing: $dep"; return 1; }
  done

  # ---------------------------------------------------------------------------
  # All helper scripts share a common prefix, namespaced by SESSION
  # ---------------------------------------------------------------------------
  local P="/tmp/devopen-${SESSION}"    # prefix for all temp files
  local S="$SESSION"                   # short alias used inside heredocs

  # ---------------------------------------------------------------------------
  # Build the 7-pane layout
  #
  #  s1: split 0 -h -p25   → 0=left(75%)    1=right(25%)
  #  s2: split 0 -v -p30   → 0=nvim(70%)    1=bot-left(30%)   2=right
  #  s3: split 1 -v -p90   → 0=nvim  1=bbar(10%)  2=bcont(90%)  3=right
  #  s4: split 3 -v -p30   → 3=top-r(70%)   4=bot-r(30%)
  #  s5: split 3 -v -p90   → 3=rbar(10%)    4=rcont(90%)      5=bot-r
  #  s6: split 5 -v -p90   → 5=dbar(10%)    6=dcont(90%)
  # ---------------------------------------------------------------------------
  tmux new-session  -d -s "$S" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -h -p 25 -t "$S:0.0" -c "$DIR"
  tmux select-pane  -t "$S:0.0"
  tmux split-window -v -p 30 -t "$S:0.0" -c "$DIR"
  tmux select-pane  -t "$S:0.1"
  tmux split-window -v -p 90 -t "$S:0.1" -c "$DIR"
  tmux select-pane  -t "$S:0.3"
  tmux split-window -v -p 30 -t "$S:0.3" -c "$DIR"
  tmux select-pane  -t "$S:0.3"
  tmux split-window -v -p 90 -t "$S:0.3" -c "$DIR"
  tmux select-pane  -t "$S:0.5"
  tmux split-window -v -p 90 -t "$S:0.5" -c "$DIR"

  tmux send-keys -t "$S:0.0" "nvim \"$FILE\"" Enter
  tmux send-keys -t "$S:0.4" "clear && claude" Enter
  tmux send-keys -t "$S:0.2" "clear && zsh" Enter
  tmux send-keys -t "$S:0.6" "while true; do clear && now; sleep 60; done" Enter

  # ---------------------------------------------------------------------------
  # Shelf windows for inactive tabs
  # ---------------------------------------------------------------------------
  tmux new-window -t "$S" -c "$DIR" -n "tabs-right"
  tmux split-window -h -t "$S:1" -c "$DIR"
  tmux send-keys -t "$S:1.0" "clear && lazygit" Enter
  tmux send-keys -t "$S:1.1" "clear && lazydocker" Enter

  tmux new-window -t "$S" -c "$DIR" -n "tabs-bottom"
  tmux send-keys -t "$S:2.0" "clear" Enter

  # ---------------------------------------------------------------------------
  # Session environment — tab state and collapse state
  # ---------------------------------------------------------------------------
  # right tabs: 3 tabs (claude=active, lazygit=slot0, lazydocker=slot1)
  _env() { tmux set-environment -t "$S" "$1" "$2"; }
  _env DEVOPEN_RTAB 0;  _env DEVOPEN_RTAB_COUNT 3; _env DEVOPEN_RMAP "-:0:1"
  _env DEVOPEN_BTAB 0;  _env DEVOPEN_BTAB_COUNT 1; _env DEVOPEN_BMAP "-"
  # collapsed state: only dcont(6) starts collapsed
  local p; for p in 0 2 4; do _env "DEVOPEN_COLLAPSED_$p" 0; _env "DEVOPEN_SIZE_$p" ""; done
  _env DEVOPEN_COLLAPSED_6 1; _env DEVOPEN_SIZE_6 ""

  # ---------------------------------------------------------------------------
  # _do_resize  — single source of truth for all pane resize operations.
  #
  # Encodes the RESIZE RULE: 9999 always runs before bar carving.
  # Called both at startup and written into the collapse script.
  #
  # Usage (as shell code, evaluated in the collapse script context):
  #   _do_resize <op>
  #
  # Ops:
  #   startup           — initial layout settlement
  #   collapse:N        — collapse content pane N
  #   uncollapse:N      — restore content pane N to $SAVED rows/cols
  #
  # The function writes a reusable resize script at $P-resize.sh which is
  # sourced by the collapse script.
  # ---------------------------------------------------------------------------
  local ESC=$'\033'
  cat > "${P}-resize.sh" << EOF
#!/bin/sh
# _do_resize OP [SAVED]
# OP: startup | collapse:N | uncollapse:N
# SAVED: saved size (only for uncollapse ops)
SESSION="${S}"
OP="\$1"
SAVED="\$2"

_r() { tmux resize-pane -t "${S}:0.\$1" -\$2 \$3 2>/dev/null; }

case "\$OP" in
  # ---- startup ---------------------------------------------------------------
  # Left col: nvim(0)=top bbar(1)=mid bcont(2)=bot
  #   9999 on nvim crushes bbar+bcont → carve bbar back to 2
  # Right: bot group dbar(5)+dcont(6) to min, rcont(4) fills right col, carve rbar(3)
  startup)
    _r 0 y 9999; _r 1 y 2
    _r 5 y 2;    _r 6 y 1
    _r 4 y 9999; _r 3 y 2
    ;;

  # ---- collapse --------------------------------------------------------------
  # pane 0 (nvim): horizontal collapse
  collapse:0)
    _r 0 x 1
    ;;
  # pane 2 (bcont): nvim 9999 crushes all → carve bbar
  collapse:2)
    _r 0 y 9999; _r 1 y 2
    ;;
  # pane 4 (rcont): shrink rcont, carve rbar; if dcont open let it fill
  collapse:4)
    _r 4 y 1; _r 3 y 2
    COLL6=\$(tmux show-environment -t "\$SESSION" DEVOPEN_COLLAPSED_6 2>/dev/null | cut -d= -f2)
    [ "\$COLL6" != "1" ] && _r 6 y 9999 && _r 5 y 2
    ;;
  # pane 6 (dcont): shrink bot group, rcont fills right col, carve rbar
  collapse:6)
    _r 5 y 2; _r 6 y 1
    _r 4 y 9999; _r 3 y 2
    ;;

  # ---- uncollapse ------------------------------------------------------------
  # pane 0 (nvim): restore horizontal width
  uncollapse:0)
    _r 0 x "\$SAVED"
    ;;
  # pane 2 (bcont): restore bcont, pin bbar, nvim takes rest
  uncollapse:2)
    _r 2 y "\$SAVED"; _r 1 y 2; _r 0 y 9999
    ;;
  # pane 4 (rcont): restore rcont, carve rbar
  uncollapse:4)
    _r 4 y "\$SAVED"; _r 3 y 2
    ;;
  # pane 6 (dcont): restore dcont, pin dbar, rcont fills top, carve rbar
  uncollapse:6)
    _r 6 y "\$SAVED"; _r 5 y 2
    _r 4 y 9999; _r 3 y 2
    ;;
esac
EOF
  chmod +x "${P}-resize.sh"

  # ---------------------------------------------------------------------------
  # collapse.sh — toggle collapse/uncollapse for a content pane
  #
  # Usage: collapse.sh <pane_index>
  # pane_index must be a collapsible content pane: 0, 2, 4, or 6
  # ---------------------------------------------------------------------------
  cat > "${P}-collapse.sh" << EOF
#!/bin/sh
SESSION="${S}"
TARGET="\$1"
[ -z "\$TARGET" ] && exit 0

CVAR="DEVOPEN_COLLAPSED_\${TARGET}"
SVAR="DEVOPEN_SIZE_\${TARGET}"
COLLAPSED=\$(tmux show-environment -t "\$SESSION" "\$CVAR" 2>/dev/null | cut -d= -f2)

if [ "\$COLLAPSED" = "1" ]; then
  SAVED=\$(tmux show-environment -t "\$SESSION" "\$SVAR" 2>/dev/null | cut -d= -f2)
  [ -z "\$SAVED" ] && SAVED=\$([ "\$TARGET" = "0" ] && echo 80 || echo 10)
  ${P}-resize.sh "uncollapse:\${TARGET}" "\$SAVED"
  tmux set-environment -t "\$SESSION" "\$CVAR" 0
else
  # Save current size before collapsing
  if [ "\$TARGET" = "0" ]; then
    SZ=\$(tmux display-message -p -t "${S}:0.0" '#{pane_width}')
  else
    SZ=\$(tmux display-message -p -t "${S}:0.\${TARGET}" '#{pane_height}')
  fi
  tmux set-environment -t "\$SESSION" "\$SVAR" "\$SZ"
  ${P}-resize.sh "collapse:\${TARGET}"
  tmux set-environment -t "\$SESSION" "\$CVAR" 1
fi
EOF
  chmod +x "${P}-collapse.sh"

  # ---------------------------------------------------------------------------
  # tab-bar renderer — generic, works for rbar and bbar
  #
  # Usage: bar.sh <ENV_TAB> <ENV_COUNT> <ENV_MAP> <content_pane> <shelf_win> <cache_file>
  # Runs as a loop inside the bar pane.
  # ---------------------------------------------------------------------------
  _write_bar() {
    local SCRIPT="$1" ET="$2" EC="$3" EM="$4" CPANE="$5" SHELF="$6" CACHE="$7"
    cat > "$SCRIPT" << EOF
#!/bin/sh
SESSION="${S}"
RESET="${ESC}[0m"
ACTIVE="${ESC}[38;5;141m"
INACTIVE="${ESC}[38;5;248m"

while tmux has-session -t "\$SESSION" 2>/dev/null; do
  COUNT=\$(tmux show-environment -t "\$SESSION" ${EC} 2>/dev/null | cut -d= -f2)
  CUR=\$(tmux show-environment   -t "\$SESSION" ${ET} 2>/dev/null | cut -d= -f2)
  MAP=\$(tmux show-environment   -t "\$SESSION" ${EM} 2>/dev/null | cut -d= -f2)
  [ -z "\$COUNT" ] && sleep 0.1 && continue

  LINE="" CACHEDATA=""
  for i in \$(seq 0 \$(( COUNT - 1 ))); do
    if [ "\$i" = "\$CUR" ]; then
      CMD=\$(tmux display-message -p -t "${CPANE}" '#{pane_current_command}' 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${ACTIVE}● \$(( i+1 )):\${CMD}\${RESET}  "
      CACHEDATA="\${CACHEDATA}\${i} * \${CMD}\n"
    else
      SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( i+1 ))p")
      CMD=\$(tmux display-message -p -t "${SHELF}.\${SLOT}" '#{pane_current_command}' 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${INACTIVE}○ \$(( i+1 )):\${CMD}\${RESET}  "
      CACHEDATA="\${CACHEDATA}\${i}   \${CMD}\n"
    fi
  done

  printf "\033[2J\033[1;1H %b\033[K" "\$LINE"
  printf "%b" "\$CACHEDATA" > "${CACHE}"
  sleep 0.1
done
EOF
    chmod +x "$SCRIPT"
  }

  _write_bar "${P}-rbar.sh" DEVOPEN_RTAB DEVOPEN_RTAB_COUNT DEVOPEN_RMAP \
    "$S:0.4" "$S:1" "${P}-rtabs.cache"
  _write_bar "${P}-bbar.sh" DEVOPEN_BTAB DEVOPEN_BTAB_COUNT DEVOPEN_BMAP \
    "$S:0.2" "$S:2" "${P}-btabs.cache"

  # ---------------------------------------------------------------------------
  # dbar renderer — dash bar (fixed single tab: calendar)
  # Uses same clear+home pattern as the tab bars for visual consistency.
  # ---------------------------------------------------------------------------
  cat > "${P}-dbar.sh" << EOF
#!/bin/bash
SESSION="${S}"
ACTIVE="${ESC}[38;5;141m"
WARN="${ESC}[38;5;215m"
RESET="${ESC}[0m"
SOON="" LAST=0

while tmux has-session -t "\$SESSION" 2>/dev/null; do
  NOW_S=\$(date "+%s")
  NOW=\$(date "+%H%M")
  if (( NOW_S - LAST >= 30 )); then
    LAST=\$NOW_S; SOON=""
    while IFS='|' read -r s e t r; do
      [ -z "\$e" ] && continue
      E=\$(echo "\$e" | tr -d ':')
      echo "\$E" | grep -qE '^[0-9]{4}$' || continue
      D=\$(( E - NOW ))
      [ "\$D" -ge 0 ] && [ "\$D" -le 5 ] && SOON=" \${WARN}󰃯\${RESET}" && break
    done <<< "\$(khal list today --format '{start-time}|{end-time}|{title}|{calendar}' 2>/dev/null)"
  fi
  printf "\033[2J\033[1;1H \${ACTIVE}● 1:calendar\${RESET}\${SOON}\033[K"
  sleep 1
done
EOF
  chmod +x "${P}-dbar.sh"

  tmux send-keys -t "$S:0.3" "${P}-rbar.sh" Enter
  tmux send-keys -t "$S:0.1" "${P}-bbar.sh" Enter
  tmux send-keys -t "$S:0.5" "${P}-dbar.sh" Enter

  # ---------------------------------------------------------------------------
  # switch.sh — swap a shelf tab into the content pane
  #
  # Usage: switch.sh <right|bottom> <tab_index>
  # ---------------------------------------------------------------------------
  cat > "${P}-switch.sh" << EOF
#!/bin/sh
SESSION="${S}"
SYS="\$1" IDX="\$2"

if [ "\$SYS" = "right" ]; then
  ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP
  CONTENT="${S}:0.4"; SHELF="${S}:1"
else
  ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP
  CONTENT="${S}:0.2"; SHELF="${S}:2"
fi

COUNT=\$(tmux show-environment -t "\$SESSION" "\$EC" | cut -d= -f2)
CUR=\$(  tmux show-environment -t "\$SESSION" "\$ET" | cut -d= -f2)
MAP=\$(  tmux show-environment -t "\$SESSION" "\$EM" | cut -d= -f2)

[ -z "\$IDX" ] || [ "\$IDX" -ge "\$COUNT" ] && exit 0
[ "\$IDX" = "\$CUR" ] && exit 0

SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( IDX+1 ))p")
tmux swap-pane -s "\$CONTENT" -t "\${SHELF}.\${SLOT}"

NEW_MAP=\$(echo "\$MAP" | tr ':' '\n' | awk \
  -v cur="\$CUR" -v idx="\$IDX" -v slot="\$SLOT" '
  NR==cur+1 { print slot; next }
  NR==idx+1 { print "-";  next }
  { print }
' | tr '\n' ':' | sed 's/:\$//')

tmux set-environment -t "\$SESSION" "\$EM" "\$NEW_MAP"
tmux set-environment -t "\$SESSION" "\$ET" "\$IDX"
tmux select-pane -t "\$CONTENT"
CMD=\$(tmux display-message -p -t "\$CONTENT" '#{pane_current_command}')
tmux display-message -t "\$SESSION" "[\$(( IDX+1 ))/\$COUNT] \$CMD"
EOF
  chmod +x "${P}-switch.sh"

  # ---------------------------------------------------------------------------
  # new-tab prompt
  # ---------------------------------------------------------------------------
  cat > "${P}-new.sh" << 'EOF'
#!/bin/sh
printf "command > "
read -r CMD
printf "%s\n" "$CMD" > "$TMPFILE"
EOF
  chmod +x "${P}-new.sh"

  # ---------------------------------------------------------------------------
  # jump.sh — fzf picker: all tabs + plain panes → writes "sys\nidx" to $TMPFILE
  # ---------------------------------------------------------------------------
  cat > "${P}-jump.sh" << EOF
#!/bin/sh
SESSION="${S}"
RC="${P}-rtabs.cache"
BC="${P}-btabs.cache"
LINES=""

CMD=\$(tmux display-message -p -t "${S}:0.0" '#{pane_current_command}' 2>/dev/null | cut -c1-8)
LINES="\${LINES}pane:0  nvim * \${CMD}\n"
LINES="\${LINES}pane:6  dash * calendar\n"

while IFS= read -r line; do
  [ -z "\$line" ] && continue
  i=\$(echo "\$line" | awk '{print \$1}')
  rest=\$(echo "\$line" | cut -d' ' -f2-)
  LINES="\${LINES}right:\${i}  right \$(( i+1 )) \${rest}\n"
done < "\$RC"

while IFS= read -r line; do
  [ -z "\$line" ] && continue
  i=\$(echo "\$line" | awk '{print \$1}')
  rest=\$(echo "\$line" | cut -d' ' -f2-)
  LINES="\${LINES}bottom:\${i}  bottom \$(( i+1 )) \${rest}\n"
done < "\$BC"

SEL=\$(printf "%b" "\$LINES" | fzf \
  --prompt="jump > " --height=100% --layout=reverse --border=none \
  --with-nth=2.. --preview-window=hidden \
  --color="prompt:#89b4fa,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#a6e3a1")

[ -z "\$SEL" ] && printf "\n\n" > "\$TMPFILE" && exit 0
KEY=\$(echo "\$SEL" | awk '{print \$1}')
printf "%s\n%s\n" "\${KEY%%:*}" "\${KEY##*:}" > "\$TMPFILE"
EOF
  chmod +x "${P}-jump.sh"

  # ---------------------------------------------------------------------------
  # kill.sh — fzf picker: inactive tabs only → writes "sys\nidx" to $TMPFILE
  # ---------------------------------------------------------------------------
  cat > "${P}-kill.sh" << EOF
#!/bin/sh
RC="${P}-rtabs.cache"
BC="${P}-btabs.cache"
LINES=""

while IFS= read -r line; do
  [ -z "\$line" ] || echo "\$line" | grep -q ' \* ' && continue
  i=\$(echo "\$line" | awk '{print \$1}')
  rest=\$(echo "\$line" | cut -d' ' -f2-)
  LINES="\${LINES}right:\${i}  right \$(( i+1 )) \${rest}\n"
done < "\$RC"

while IFS= read -r line; do
  [ -z "\$line" ] || echo "\$line" | grep -q ' \* ' && continue
  i=\$(echo "\$line" | awk '{print \$1}')
  rest=\$(echo "\$line" | cut -d' ' -f2-)
  LINES="\${LINES}bottom:\${i}  bottom \$(( i+1 )) \${rest}\n"
done < "\$BC"

[ -z "\$LINES" ] && printf "\n\n" > "\$TMPFILE" && exit 0

SEL=\$(printf "%b" "\$LINES" | fzf \
  --prompt="kill > " --height=100% --layout=reverse --border=none \
  --with-nth=2.. --preview-window=hidden \
  --color="prompt:#f38ba8,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#f38ba8")

[ -z "\$SEL" ] && printf "\n\n" > "\$TMPFILE" && exit 0
KEY=\$(echo "\$SEL" | awk '{print \$1}')
printf "%s\n%s\n" "\${KEY%%:*}" "\${KEY##*:}" > "\$TMPFILE"
EOF
  chmod +x "${P}-kill.sh"

  # ---------------------------------------------------------------------------
  # _tab_ctx helper — written into every keybinding that needs tab context.
  # Resolves PANE index → SYS + env var names + content/shelf targets.
  # When SYS is empty the caller should exit 0 (wrong context).
  # ---------------------------------------------------------------------------
  local TAB_CTX='
    PANE=$(tmux display-message -p "#{pane_index}")
    case "$PANE" in
      3|4) SYS=right;  ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP ;;
      1|2) SYS=bottom; ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP ;;
      *)   SYS="" ;;
    esac
    [ -z "$SYS" ] && exit 0
    COUNT=$(tmux show-environment -t $SESSION $EC | cut -d= -f2)
    CUR=$(  tmux show-environment -t $SESSION $ET | cut -d= -f2)
    MAP=$(  tmux show-environment -t $SESSION $EM | cut -d= -f2)
  '

  # ---------------------------------------------------------------------------
  # _collapse_ctx helper — resolves PANE index → TARGET content pane
  # ---------------------------------------------------------------------------
  local COLLAPSE_CTX='
    PANE=$(tmux display-message -p "#{pane_index}")
    case "$PANE" in
      0)   TARGET=0 ;;
      1|2) TARGET=2 ;;
      3|4) TARGET=4 ;;
      5|6) TARGET=6 ;;
      *)   exit 0   ;;
    esac
  '

  # ---------------------------------------------------------------------------
  # Key bindings
  # ---------------------------------------------------------------------------
  local SW="${P}-switch.sh"
  local COL="${P}-collapse.sh"

  # prefix+T — cycle next tab
  tmux bind-key -T prefix T run-shell "
    SESSION=\$(tmux display-message -p '#S')
    ${TAB_CTX}
    ${SW} \$SYS \$(( (CUR+1) % COUNT ))
  "

  # prefix+N — new tab with optional command
  tmux bind-key -T prefix N run-shell "
    SESSION=\$(tmux display-message -p '#S')
    ${TAB_CTX}
    CONTENT=\$([ \"\$SYS\" = right ] && echo \"${S}:0.4\" || echo \"${S}:0.2\")
    SHELF=\$(  [ \"\$SYS\" = right ] && echo \"${S}:1\"   || echo \"${S}:2\")
    TMPFILE=\$(mktemp /tmp/devopen-cmd-XXXX)
    tmux popup -E -w 40 -h 3 \"TMPFILE=\$TMPFILE ${P}-new.sh\"
    CMD=\$(cat \$TMPFILE); rm -f \$TMPFILE
    DIR=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_path}')
    tmux split-window -h -t \"\$SHELF\" -c \"\$DIR\"
    NEW_SLOT=\$COUNT
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${NEW_SLOT}\"
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v cur=\"\$CUR\" -v slot=\"\$NEW_SLOT\" \
      'NR==cur+1{print slot;next}{print}' \
      | tr '\n' ':' | sed 's/:\$//'):\"-\"
    tmux set-environment -t \$SESSION \$EC \$(( COUNT+1 ))
    tmux set-environment -t \$SESSION \$ET \$COUNT
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    [ -n \"\$CMD\" ] && tmux send-keys -t \"\$CONTENT\" \"\$CMD\" C-m
    tmux display-message \"[\$(( COUNT+1 ))/\$(( COUNT+1 ))] new tab\"
  "

  # prefix+X — kill current tab (refuse if last)
  tmux bind-key -T prefix X run-shell "
    SESSION=\$(tmux display-message -p '#S')
    ${TAB_CTX}
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0
    CONTENT=\$([ \"\$SYS\" = right ] && echo \"${S}:0.4\" || echo \"${S}:0.2\")
    SHELF=\$(  [ \"\$SYS\" = right ] && echo \"${S}:1\"   || echo \"${S}:2\")
    PREV=\$(( (CUR-1+COUNT) % COUNT ))
    PREV_SLOT=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( PREV+1 ))p\")
    tmux swap-pane  -s \"\$CONTENT\" -t \"\${SHELF}.\${PREV_SLOT}\"
    tmux kill-pane  -t \"\${SHELF}.\${PREV_SLOT}\"
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v cur=\"\$CUR\" -v prev=\"\$PREV\" -v slot=\"\$PREV_SLOT\" '
      NR==prev+1{next}
      NR==cur+1{print \"-\";next}
      {\$0!="-" && \$0+0>slot ? \$0=\$0-1:1; print}
    ' | tr '\n' ':' | sed 's/:\$//')
    tmux set-environment -t \$SESSION \$EC \$(( COUNT-1 ))
    tmux set-environment -t \$SESSION \$ET \$PREV
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    CMD=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_command}')
    tmux display-message \"[\$(( PREV+1 ))/\$(( COUNT-1 ))] \$CMD\"
  "

  # prefix+C — collapse / uncollapse (calls shared collapse.sh)
  tmux bind-key -T prefix C run-shell "
    SESSION=\$(tmux display-message -p '#S')
    ${COLLAPSE_CTX}
    ${COL} \$TARGET
  "

  # prefix+G — fzf jump: uncollapse target if needed, then focus
  tmux bind-key -T prefix G run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${P}-jump.sh\"
    SYS=\$(sed -n '1p' \$TMPFILE)
    IDX=\$(sed -n '2p' \$TMPFILE | tr -d '[:space:]')
    rm -f \$TMPFILE
    [ -z \"\$SYS\" ] && exit 0
    case \"\$SYS\" in
      pane)
        # Map pane 6 (dash) to collapse target 6, pane 0 → target 0
        TARGET=\$IDX
        CVAR=\"DEVOPEN_COLLAPSED_\${TARGET}\"
        SVAR=\"DEVOPEN_SIZE_\${TARGET}\"
        COLLAPSED=\$(tmux show-environment -t \$SESSION \$CVAR 2>/dev/null | cut -d= -f2)
        if [ \"\$COLLAPSED\" = \"1\" ]; then
          SAVED=\$(tmux show-environment -t \$SESSION \$SVAR 2>/dev/null | cut -d= -f2)
          [ -z \"\$SAVED\" ] && SAVED=\$([ \"\$TARGET\" = \"0\" ] && echo 80 || echo 10)
          ${P}-resize.sh \"uncollapse:\${TARGET}\" \"\$SAVED\"
          tmux set-environment -t \$SESSION \$CVAR 0
        fi
        tmux select-pane -t \"${S}:0.\${IDX}\"
        ;;
      right)  ${SW} right  \$IDX ;;
      bottom) ${SW} bottom \$IDX ;;
    esac
  "

  # prefix+D — fzf kill inactive tab
  tmux bind-key -T prefix D run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${P}-kill.sh\"
    SYS=\$(sed -n '1p' \$TMPFILE)
    IDX=\$(sed -n '2p' \$TMPFILE | tr -d '[:space:]')
    rm -f \$TMPFILE
    [ -z \"\$SYS\" ] && exit 0
    if [ \"\$SYS\" = right ]; then
      ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; SHELF=\"${S}:1\"
    else
      ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; SHELF=\"${S}:2\"
    fi
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(  tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(  tmux show-environment -t \$SESSION \$EM | cut -d= -f2)
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0
    SLOT=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( IDX+1 ))p\")
    tmux kill-pane -t \"\${SHELF}.\${SLOT}\"
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v idx=\"\$IDX\" -v slot=\"\$SLOT\" '
      NR==idx+1{next}
      {\$0!="-" && \$0+0>slot ? \$0=\$0-1:1; print}
    ' | tr '\n' ':' | sed 's/:\$//')
    NEWCUR=\$(( IDX < CUR ? CUR-1 : CUR ))
    tmux set-environment -t \$SESSION \$EC \$(( COUNT-1 ))
    tmux set-environment -t \$SESSION \$ET \$NEWCUR
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux display-message \"Killed \$SYS tab \$(( IDX+1 )) [\$(( COUNT-1 )) left]\"
  "

  # Alt+1..9 — jump to tab N by number (context-aware)
  local i
  for i in 1 2 3 4 5 6 7 8 9; do
    tmux bind-key -n "M-$i" run-shell "
      PANE=\$(tmux display-message -p '#{pane_index}')
      case \"\$PANE\" in
        3|4) ${SW} right  $(( i-1 )) ;;
        1|2) ${SW} bottom $(( i-1 )) ;;
        *)   tmux send-keys 'M-$i' ;;
      esac
    "
  done

  # h/l/←/→ — prev/next tab on bar panes only
  _bind_nav() {
    local KEY="$1" OP="$2"  # OP is a shell arithmetic expr using CUR and COUNT
    tmux bind-key -n "$KEY" run-shell "
      SESSION=\$(tmux display-message -p '#S')
      PANE=\$(  tmux display-message -p '#{pane_index}')
      case \"\$PANE\" in
        3) ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; SYS=right  ;;
        1) ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; SYS=bottom ;;
        *) tmux send-keys '$KEY'; exit 0 ;;
      esac
      COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
      CUR=\$(  tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
      ${SW} \$SYS \$(( ($OP) % COUNT ))
    "
  }
  _bind_nav h     "(CUR-1+COUNT)"
  _bind_nav Left  "(CUR-1+COUNT)"
  _bind_nav l     "(CUR+1)"
  _bind_nav Right "(CUR+1)"

  # ---------------------------------------------------------------------------
  # Initial layout settlement — runs in background after attach
  # ---------------------------------------------------------------------------
  tmux select-window -t "$S:0"
  tmux select-pane   -t "$S:0.0"
  ( sleep 0.3; "${P}-resize.sh" startup ) &
  tmux attach -t "$S"
}

# =============================================================================
# devclose — tear down the workspace
# =============================================================================
devclose() {
  local SESSION
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  [[ -z "$SESSION" ]] && { echo "devclose: not inside a tmux session"; return 1; }
  echo "devclose: closing '$SESSION'..."

  rm -f /tmp/devopen-${SESSION}-*

  local k
  for k in h l Left Right; do tmux unbind-key -n "$k" 2>/dev/null; done
  for k in 1 2 3 4 5 6 7 8 9; do tmux unbind-key -n "M-$k" 2>/dev/null; done
  for k in T N X C G D; do tmux unbind-key -T prefix "$k" 2>/dev/null; done

  tmux kill-session -t "$SESSION"
}
