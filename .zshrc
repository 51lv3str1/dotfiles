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

# ─── kdash — terminal calendar dashboard ─────────────────────────────────────
# Add this to your ~/.zshrc
# Usage: kdash

function kdash() {
  local reset="\033[0m"
  local bold="\033[1m"
  local dim="\033[2m"
  local italic="\033[3m"
  local white="\033[97m"
  local gray="\033[38;5;245m"
  local accent="\033[38;5;116m"
  local accent_bold="\033[1;38;5;116m"
  local border="\033[38;5;238m"
  local muted="\033[38;5;240m"

  local now_int=$(date "+%H%M")
  local today_num=$(date "+%-d")
  local pad="  "

  local color_google="\033[38;5;75m"
  local color_familia="\033[38;5;213m"
  local color_festivos="\033[38;5;120m"
  local color_daruma="\033[38;5;215m"
  local color_allaria="\033[38;5;159m"
  local color_default="\033[97m"

  local icon_google="󰊫"
  local icon_familia="󰉌"
  local icon_festivos="󰃦"
  local icon_daruma="󰃯"
  local icon_allaria="󰃯"
  local icon_default="󰃯"

  local cal_w=22
  local right_w=38
  local i=0

  # ── build left panel: mini calendar ──────────────────────────────────────────
  local -a left_lines
  local lnum=0
  while IFS= read -r line; do
    if (( lnum == 0 )); then
      local mh_len=${#line}
      local mh_pad=$(( (cal_w - mh_len) / 2 ))
      local mh_sp=""
      i=0; while (( i < mh_pad )); do mh_sp+=" "; (( i++ )); done
      left_lines+=("${mh_sp}${accent_bold}${line}${reset}")
    elif (( lnum == 1 )); then
      left_lines+=("${gray}${line}${reset}")
    else
      # manually highlight today_num as a word in the line
      local before="" after="" found=0
      local rest="$line"
      local styled=""
      while [[ -n "$rest" ]]; do
        # try to match leading spaces + today_num as a number token
        if [[ "$rest" =~ ^([[:space:]]*)([0-9]+)(.*) ]]; then
          local spaces="${match[1]}"
          local num="${match[2]}"
          local tail="${match[3]}"
          if [[ "$num" == "$today_num" ]]; then
            styled+="${spaces}${reset}${bold}${accent}${num}${reset}${dim}"
          else
            styled+="${spaces}${num}"
          fi
          rest="$tail"
        else
          # non-numeric char, pass through
          styled+="${rest[1]}"
          rest="${rest:1}"
        fi
      done
      left_lines+=("${dim}${styled}${reset}")
    fi
    (( lnum++ ))
  done <<< "$(cal)"

  # ── build right panel ─────────────────────────────────────────────────────────
  local -a right_lines

  local day_name=$(date "+%A")
  local day_num=$(date "+%d")
  local month_year=$(date "+%B %Y")
  local time_now=$(date "+%H:%M")
  local location="Buenos Aires"
  right_lines+=("${muted}󰍎 ${reset}${dim}${location}${reset}  ${accent_bold}󰃭${reset}  ${bold}${white}${day_name}${reset}  ${muted}·${reset}  ${accent_bold}${day_num}${reset}  ${gray}${month_year}${reset}  ${muted}·${reset}  ${accent}${time_now}${reset}")

  local rdiv=""
  i=0; while (( i < right_w )); do rdiv+="─"; (( i++ )); done
  right_lines+=("${border}${rdiv}${reset}")

  # weather
  local weather_cache="/tmp/kdash_weather"
  if [[ ! -f "$weather_cache" ]] || (( $(date +%s) - $(date -r "$weather_cache" +%s 2>/dev/null || echo 0) > 1800 )); then
    (curl -sf "wttr.in/Buenos+Aires?format=%c+%t+feels+%f+·+%h+hum+·+%w" > "$weather_cache" 2>/dev/null &)
  fi

  local weather=""
  [[ -f "$weather_cache" ]] && weather=$(cat "$weather_cache")

  if [[ -n "$weather" ]]; then
    local w_icon w_temp w_feels w_hum w_wind
    w_icon=$(echo "$weather" | grep -oP '^\S+')
    w_temp=$(echo "$weather" | grep -oP '[+-]\d+°C' | head -1)
    w_feels=$(echo "$weather" | grep -oP '[+-]\d+°C' | tail -1)
    w_hum=$(echo "$weather" | grep -oP '\d+%')
    w_wind=$(echo "$weather" | grep -oP '[↖↗↘↙←→↑↓]\d+km/h')
    right_lines+=("")
    right_lines+=("${white}${w_icon}${reset}  ${accent_bold}${w_temp}${reset}  ${dim}feels${reset} ${gray}${w_feels}${reset}  ${muted}·${reset}  ${accent}${w_hum}${reset} ${dim}hum${reset}  ${muted}·${reset}  ${gray}${w_wind}${reset}")
    right_lines+=("")
    right_lines+=("${border}${rdiv}${reset}")
  fi

  # events
  local raw_events
  raw_events=$(khal list today --format "{start-time}|{end-time}|{title}|{calendar}" 2>/dev/null)

  if [[ -z "$raw_events" ]]; then
    right_lines+=("")
    right_lines+=("  ${muted}${italic}no events today${reset}")
  else
    local -A seen_events
    while IFS='|' read -r start end title calendar; do
      [[ "$start" =~ ^(Today|Tomorrow|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|Lunes|Martes|Miercoles|Jueves|Viernes|Sabado|Domingo) ]] && continue
      [[ -z "$title" ]] && continue
      local event_key="${start}|${title}"
      [[ -n "${seen_events[$event_key]}" ]] && continue
      seen_events[$event_key]=1

      local color="$color_default" icon="$icon_default"
      case "$calendar" in
        google)   color="$color_google";   icon="$icon_google"   ;;
        familia)  color="$color_familia";  icon="$icon_familia"  ;;
        festivos) color="$color_festivos"; icon="$icon_festivos" ;;
        daruma)   color="$color_daruma";   icon="$icon_daruma"   ;;
        allaria)  color="$color_allaria";  icon="$icon_allaria"  ;;
      esac

      local cal_label="${calendar:-?}"
      local time_style="" title_style="$white"
      local eline=""

      if [[ -z "$start" ]]; then
        eline=$(printf "${color}${icon}${reset}  ${gray}%-10s${reset}  ${dim}all day${reset}  ${bold}${white}%s${reset}" "$cal_label" "$title")
      else
        local start_int=${start//:/}
        local end_int=2359
        [[ -n "$end" ]] && end_int=${end//:/}
        if (( start_int < now_int )); then
          time_style="$dim"; title_style="$dim"
        fi
        if (( start_int <= now_int && now_int <= end_int )); then
          time_style=""; title_style="$white"
        fi
        eline=$(printf "${color}${icon}${reset}  ${gray}%-10s${reset}  ${time_style}${color}${bold}%s${reset}${time_style} → %s${reset}  ${title_style}%s${reset}" "$cal_label" "$start" "$end" "$title")
      fi
      right_lines+=("$eline")
    done <<< "$raw_events"
  fi

  # ── render side by side ───────────────────────────────────────────────────────
  local total=$(( ${#left_lines[@]} > ${#right_lines[@]} ? ${#left_lines[@]} : ${#right_lines[@]} ))
  local sep="  ${border}│${reset}  "

  echo ""
  for (( row=1; row<=total; row++ )); do
    local left="${left_lines[$row]:-}"
    local right="${right_lines[$row]:-}"
    [[ -z "$left" && -z "$right" ]] && continue

    local ln=$(printf '%b' "$left" | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n' | wc -m)
    local lp=""
    i=0; while (( i < cal_w - ln + 1 )); do lp+=" "; (( i++ )); done

    echo -e "${pad}${left}${lp}${sep}${right}"
  done

  echo ""
}

# =============================================================================
# devopen / devclose — tmux development workspace with virtual tab system
# =============================================================================
#
# USAGE
#   devopen [file|dir]   Open a workspace rooted at file or directory.
#   devclose             Tear down the current workspace and clean up.
#
# LAYOUT (pane indices in window 0)
#
#   ┌─────────────────────┬──────────┐
#   │                     │  rbar  3 │  right tab-bar     (2 rows, full height)
#   │       nvim  0       ├──────────┤
#   │                     │ rcont  4 │  right tab-content (full height)
#   ├─────────────────────┤          │
#   │  bbar  1            │          │  bottom tab-bar    (nvim-width, 2 rows)
#   ├─────────────────────┤          │
#   │  bcont 2            │          │  bottom tab-content (nvim-width)
#   └─────────────────────┴──────────┘
#
# TAB SYSTEM
#   Each content pane (rcont=4, bcont=2) is backed by a "shelf" window whose
#   panes hold inactive tabs. Switching swaps the target shelf pane into the
#   content pane via `tmux swap-pane`.
#
#   A position MAP (colon-separated, stored in tmux environment) tracks which
#   shelf slot holds each logical tab, since swap-pane does not renumber panes.
#   MAP format: "-:0:1"  means tab0=active("-"), tab1=slot0, tab2=slot1.
#
#   Shelf windows:
#     window 1  (tabs-right)   — inactive right tabs
#     window 2  (tabs-bottom)  — inactive bottom tabs
#
# TMUX ENVIRONMENT VARIABLES (per session)
#   DEVOPEN_RTAB        0-based index of the currently active right tab
#   DEVOPEN_RTAB_COUNT  total number of right tabs
#   DEVOPEN_RMAP        position map for right tabs
#   DEVOPEN_BTAB        0-based index of the currently active bottom tab
#   DEVOPEN_BTAB_COUNT  total number of bottom tabs
#   DEVOPEN_BMAP        position map for bottom tabs
#
# KEY BINDINGS
#   prefix+T        cycle to next tab (context-aware: right or bottom)
#   prefix+N        open a new tab with optional command prompt
#   prefix+X        kill the current tab (refuses if last tab)
#   prefix+G        fzf picker — jump to any tab or plain pane; focuses it
#   prefix+D        fzf picker — kill any inactive tab
#   h / ← / l / →  prev/next tab (only active on tab-bar panes 1 and 3)
#   Alt+1..9        jump to tab N by number (context-aware)
#
# DEPENDENCIES: nvim, claude, lazygit, lazydocker, fzf
# =============================================================================

devopen() {
  # ---------------------------------------------------------------------------
  # Argument handling — resolve target file and working directory
  # ---------------------------------------------------------------------------
  local FILE="${1:-.}"
  local DIR
  if [[ -d "$FILE" ]]; then
    DIR=$(realpath "$FILE")
    FILE="."
  else
    DIR=$(realpath "$(dirname "$FILE")")
  fi
  local NAME=$(basename "${1:-.}")
  local SESSION="${NAME}-$(date +%s)"

  # ---------------------------------------------------------------------------
  # Dependency check
  # ---------------------------------------------------------------------------
  local dep
  for dep in nvim claude lazygit lazydocker fzf; do
    command -v "$dep" &>/dev/null || { echo "devopen: missing dependency: $dep"; return 1; }
  done

  # ---------------------------------------------------------------------------
  # Temp file paths — all namespaced by SESSION to support concurrent workspaces
  # ---------------------------------------------------------------------------
  local TMP="/tmp/devopen-${SESSION}"
  local RBAR_SCRIPT="${TMP}-rbar.sh"       # right tab-bar renderer
  local BBAR_SCRIPT="${TMP}-bbar.sh"       # bottom tab-bar renderer
  local RCACHE="${TMP}-rtabs.cache"        # right tab fzf cache
  local BCACHE="${TMP}-btabs.cache"        # bottom tab fzf cache
  local SWITCH_SCRIPT="${TMP}-switch.sh"   # tab switch logic
  local NEW_SCRIPT="${TMP}-new.sh"         # new tab prompt
  local JUMP_SCRIPT="${TMP}-jump.sh"       # fzf jump picker
  local KILL_SCRIPT="${TMP}-kill.sh"       # fzf kill picker

  # ---------------------------------------------------------------------------
  # Build layout — splits must be done in strict top-left→bottom-right order
  # so tmux pane numbering remains predictable (renumbers by screen position).
  #
  #   Step 1: split right column off pane 0 at full terminal height
  #   Step 2: split bottom strip off pane 0 (left column only)
  #   Step 3: subdivide bottom strip into bbar + bcont
  #   Step 4: subdivide right column into rbar + rcont
  # ---------------------------------------------------------------------------
  tmux new-session -d -s "$SESSION" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -h -p 25 -t "$SESSION":0.0 -c "$DIR"   # → pane 0=left, 1=right
  tmux select-pane  -t "$SESSION":0.0
  tmux split-window -v -p 30 -t "$SESSION":0.0 -c "$DIR"   # → 0=nvim, 1=bot-left, 2=right
  tmux select-pane  -t "$SESSION":0.1
  tmux split-window -v -p 90 -t "$SESSION":0.1 -c "$DIR"   # → 1=bbar, 2=bcont, 3=right
  tmux select-pane  -t "$SESSION":0.3
  tmux split-window -v -p 90 -t "$SESSION":0.3 -c "$DIR"   # → 3=rbar, 4=rcont

  # Launch initial programs into their panes
  tmux send-keys -t "$SESSION":0.0 "nvim \"$FILE\"" Enter
  tmux send-keys -t "$SESSION":0.4 "clear && claude" Enter
  tmux send-keys -t "$SESSION":0.2 "clear && zsh" Enter

  # ---------------------------------------------------------------------------
  # Shelf windows — hold inactive tabs off-screen
  #
  #   window 1 (tabs-right):  lazygit at slot 0, lazydocker at slot 1
  #   window 2 (tabs-bottom): one zsh pane at slot 0
  #
  #   Initial MAP for right:  "-:0:1"  (tab0=active, tab1=slot0, tab2=slot1)
  #   Initial MAP for bottom: "-"      (tab0=active, no inactive tabs)
  # ---------------------------------------------------------------------------
  tmux new-window -t "$SESSION" -c "$DIR" -n "tabs-right"
  tmux split-window -h -t "$SESSION":1 -c "$DIR"
  tmux send-keys -t "$SESSION":1.0 "clear && lazygit" Enter
  tmux send-keys -t "$SESSION":1.1 "clear && lazydocker" Enter
  tmux set-environment -t "$SESSION" DEVOPEN_RTAB       0
  tmux set-environment -t "$SESSION" DEVOPEN_RTAB_COUNT 3
  tmux set-environment -t "$SESSION" DEVOPEN_RMAP       "-:0:1"

  tmux new-window -t "$SESSION" -c "$DIR" -n "tabs-bottom"
  tmux send-keys -t "$SESSION":2.0 "clear" Enter
  tmux set-environment -t "$SESSION" DEVOPEN_BTAB       0
  tmux set-environment -t "$SESSION" DEVOPEN_BTAB_COUNT 1
  tmux set-environment -t "$SESSION" DEVOPEN_BMAP       "-"

  # ---------------------------------------------------------------------------
  # Tab-bar renderer — shared logic, instantiated twice (right and bottom).
  #
  # Runs in a tight loop (100ms), reading COUNT/CUR/MAP from tmux environment.
  # For each logical tab i:
  #   - active tab (i == CUR): read command from content pane directly
  #   - inactive tab:          look up shelf slot via MAP, read from shelf window
  # Writes two outputs each tick:
  #   - LINE  printed to terminal (ANSI colored tab labels)
  #   - CACHE written to file for fzf pickers to consume
  #
  # Arguments baked in at generation time (heredoc expansion):
  #   SESSION, ENV_TAB, ENV_COUNT, ENV_MAP, CONTENT_PANE, SHELF_WIN, TABCACHE
  # ---------------------------------------------------------------------------
  _devopen_write_renderer() {
    local SCRIPT="$1"
    local ENV_TAB="$2"
    local ENV_COUNT="$3"
    local ENV_MAP="$4"
    local CONTENT_PANE="$5"
    local SHELF_WIN="$6"
    local TABCACHE="$7"

    # Use $'...' quoting so \033 is a real escape character in the generated script
    local ESC=$'\033'
    cat > "$SCRIPT" << EOF
#!/bin/sh
SESSION="${SESSION}"
TABCACHE="${TABCACHE}"
RESET="${ESC}[0m"
ACTIVE="${ESC}[38;5;141m"    # purple — active tab label
INACTIVE="${ESC}[38;5;248m"  # grey   — inactive tab label
CLEAR="${ESC}[H${ESC}[2J"
SEP="  "

while tmux has-session -t "\$SESSION" 2>/dev/null; do
  COUNT=\$(tmux show-environment -t "\$SESSION" ${ENV_COUNT} 2>/dev/null | cut -d= -f2)
  CUR=\$(tmux show-environment   -t "\$SESSION" ${ENV_TAB}   2>/dev/null | cut -d= -f2)
  MAP=\$(tmux show-environment   -t "\$SESSION" ${ENV_MAP}   2>/dev/null | cut -d= -f2)
  [ -z "\$COUNT" ] && sleep 0.1 && continue

  LINE=""
  CACHE=""
  for i in \$(seq 0 \$(( COUNT - 1 ))); do
    NUM=\$(( i + 1 ))
    if [ "\$i" = "\$CUR" ]; then
      # Active tab — read live from content pane
      CMD=\$(tmux display-message -p -t "${CONTENT_PANE}" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${ACTIVE}● \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i} * \${CMD}\n"
    else
      # Inactive tab — look up its shelf slot from MAP
      SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( i + 1 ))p")
      CMD=\$(tmux display-message -p -t "${SHELF_WIN}.\${SLOT}" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${INACTIVE}○ \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i}   \${CMD}\n"
    fi
  done

  printf "%s %s\n" "\$CLEAR" "\$LINE"
  printf "%b" "\$CACHE" > "\$TABCACHE"
  sleep 0.1
done
EOF
    chmod +x "$SCRIPT"
  }

  _devopen_write_renderer \
    "$RBAR_SCRIPT" DEVOPEN_RTAB DEVOPEN_RTAB_COUNT DEVOPEN_RMAP \
    "$SESSION:0.4" "$SESSION:1" "$RCACHE"

  _devopen_write_renderer \
    "$BBAR_SCRIPT" DEVOPEN_BTAB DEVOPEN_BTAB_COUNT DEVOPEN_BMAP \
    "$SESSION:0.2" "$SESSION:2" "$BCACHE"

  tmux send-keys -t "$SESSION":0.3 "$RBAR_SCRIPT" Enter
  tmux send-keys -t "$SESSION":0.1 "$BBAR_SCRIPT" Enter

  # ---------------------------------------------------------------------------
  # Switch script — moves a logical tab into the content pane.
  #
  # Usage: switch.sh <right|bottom> <tab-index>
  #
  # Algorithm:
  #   1. Look up target tab's shelf slot from MAP.
  #   2. swap-pane: content pane ↔ target shelf slot.
  #      (Content now shows target; target slot now holds the previous active.)
  #   3. Update MAP: mark target as active ("-"), assign old content to target slot.
  # ---------------------------------------------------------------------------
  cat > "$SWITCH_SCRIPT" << EOF
#!/bin/sh
SESSION="${SESSION}"
SYSTEM="\$1"
IDX="\$2"

# Resolve system-specific variables
if [ "\$SYSTEM" = "right" ]; then
  ENV_TAB="DEVOPEN_RTAB";   ENV_COUNT="DEVOPEN_RTAB_COUNT"; ENV_MAP="DEVOPEN_RMAP"
  CONTENT="${SESSION}:0.4"; SHELF="${SESSION}:1"
else
  ENV_TAB="DEVOPEN_BTAB";   ENV_COUNT="DEVOPEN_BTAB_COUNT"; ENV_MAP="DEVOPEN_BMAP"
  CONTENT="${SESSION}:0.2"; SHELF="${SESSION}:2"
fi

COUNT=\$(tmux show-environment -t "\$SESSION" "\$ENV_COUNT" | cut -d= -f2)
CUR=\$(tmux show-environment   -t "\$SESSION" "\$ENV_TAB"   | cut -d= -f2)
MAP=\$(tmux show-environment   -t "\$SESSION" "\$ENV_MAP"   | cut -d= -f2)

[ -z "\$IDX" ]            && exit 0
[ "\$IDX" -ge "\$COUNT" ] && tmux display-message -t "\$SESSION" "No tab \$(( IDX + 1 ))" && exit 0
[ "\$IDX" = "\$CUR" ]     && exit 0

# Get the shelf slot that holds the target tab
TARGET_SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( IDX + 1 ))p")

# Swap: content pane ↔ target shelf slot
tmux swap-pane -s "\$CONTENT" -t "\${SHELF}.\${TARGET_SLOT}"

# Update MAP: old-active → TARGET_SLOT, new-active → "-"
NEW_MAP=\$(echo "\$MAP" | tr ':' '\n' | awk \
  -v cur="\$CUR" -v idx="\$IDX" -v slot="\$TARGET_SLOT" '
  NR == cur+1 { print slot; next }
  NR == idx+1 { print "-";  next }
  { print }
' | tr '\n' ':' | sed 's/:\$//')

tmux set-environment -t "\$SESSION" "\$ENV_MAP" "\$NEW_MAP"
tmux set-environment -t "\$SESSION" "\$ENV_TAB" "\$IDX"
tmux select-pane -t "\$CONTENT"

CMD=\$(tmux display-message -p -t "\$CONTENT" "#{pane_current_command}")
tmux display-message -t "\$SESSION" "[\$(( IDX + 1 ))/\$COUNT] \$CMD"
EOF
  chmod +x "$SWITCH_SCRIPT"

  # ---------------------------------------------------------------------------
  # New-tab prompt script — reads a command from the user via popup.
  # Writes the command (may be empty) to $TMPFILE for the caller to consume.
  # ---------------------------------------------------------------------------
  cat > "$NEW_SCRIPT" << 'EOF'
#!/bin/sh
printf "command > "
read -r CMD
printf "%s\n" "$CMD" > "$TMPFILE"
EOF
  chmod +x "$NEW_SCRIPT"

  # ---------------------------------------------------------------------------
  # Jump picker — builds a unified fzf list of every pane and tab.
  #
  # Entry format (two fields, field 1 hidden via --with-nth=2..):
  #   <system>:<0-idx>  <system>:<1-idx> <marker> <cmd>
  #   pane:0            pane:0           *         nvim
  #   right:0           right:1          *         claude
  #   right:1           right:2                    lazygit
  #   bottom:0          bottom:1         *         zsh
  #
  # Field 1 (hidden) carries the 0-based index used by the switch script.
  # Field 2+ is what the user sees — 1-based, consistent with the tab-bar.
  # On selection, writes "<system>\n<0-idx>" to $TMPFILE.
  # ---------------------------------------------------------------------------
  cat > "$JUMP_SCRIPT" << EOF
#!/bin/sh
RCACHE="${RCACHE}"
BCACHE="${BCACHE}"
SESSION="${SESSION}"
COMBINED=""

# Plain pane: nvim (pane 0) — treated as a single-tab pane
CMD=\$(tmux display-message -p -t "\${SESSION}:0.0" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
COMBINED="\${COMBINED}pane:0 pane:0 * \${CMD}\n"

# Right tabs — sourced from renderer cache
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\$(( IDX + 1 )) \${REST}\n"
done < "\$RCACHE"

# Bottom tabs — sourced from renderer cache
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}bottom:\${IDX} bottom:\$(( IDX + 1 )) \${REST}\n"
done < "\$BCACHE"

SELECTED=\$(printf "%b" "\$COMBINED" | fzf \
  --prompt="jump > " \
  --height=100% --layout=reverse --border=none \
  --with-nth=2.. \
  --color="prompt:#89b4fa,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#a6e3a1" \
  --preview-window=hidden)

[ -z "\$SELECTED" ] && printf "\n" > "\$TMPFILE" && exit 0
SYS=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f1)
IDX=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f2)
printf "%s\n%s\n" "\$SYS" "\$IDX" > "\$TMPFILE"
EOF
  chmod +x "$JUMP_SCRIPT"

  # ---------------------------------------------------------------------------
  # Kill picker — same format as jump picker but excludes active tabs (marked *)
  # and does not include plain panes (they can't be killed via this mechanism).
  # ---------------------------------------------------------------------------
  cat > "$KILL_SCRIPT" << EOF
#!/bin/sh
RCACHE="${RCACHE}"
BCACHE="${BCACHE}"
COMBINED=""

# Right inactive tabs only
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  echo "\$line" | grep -q " \* " && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\$(( IDX + 1 )) \${REST}\n"
done < "\$RCACHE"

# Bottom inactive tabs only
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  echo "\$line" | grep -q " \* " && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}bottom:\${IDX} bottom:\$(( IDX + 1 )) \${REST}\n"
done < "\$BCACHE"

[ -z "\$COMBINED" ] && printf "\n" > "\$TMPFILE" && exit 0

SELECTED=\$(printf "%b" "\$COMBINED" | fzf \
  --prompt="kill > " \
  --height=100% --layout=reverse --border=none \
  --with-nth=2.. \
  --color="prompt:#f38ba8,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#f38ba8" \
  --preview-window=hidden)

[ -z "\$SELECTED" ] && printf "\n" > "\$TMPFILE" && exit 0
SYS=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f1)
IDX=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f2)
printf "%s\n%s\n" "\$SYS" "\$IDX" > "\$TMPFILE"
EOF
  chmod +x "$KILL_SCRIPT"

  # Capture script paths for use inside bind-key run-shell strings
  local SWITCH="$SWITCH_SCRIPT"
  local NEW="$NEW_SCRIPT"
  local JUMP="$JUMP_SCRIPT"
  local KILL="$KILL_SCRIPT"

  # ---------------------------------------------------------------------------
  # Key bindings
  # ---------------------------------------------------------------------------

  # prefix+T — cycle to next tab (context-aware: checks which pane is active)
  tmux bind-key -T prefix T run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; SYS=right  ;;
      1|2) ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; SYS=bottom ;;
      *) exit 0 ;;
    esac
    CUR=\$(tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    ${SWITCH} \$SYS \$(( (CUR + 1) % COUNT ))
  "

  # prefix+N — open a new tab in the current panel, with optional command
  tmux bind-key -T prefix N run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) EC=DEVOPEN_RTAB_COUNT; ET=DEVOPEN_RTAB; EM=DEVOPEN_RMAP; CONTENT=\"${SESSION}:0.4\"; SHELF=\"${SESSION}:1\" ;;
      1|2) EC=DEVOPEN_BTAB_COUNT; ET=DEVOPEN_BTAB; EM=DEVOPEN_BMAP; CONTENT=\"${SESSION}:0.2\"; SHELF=\"${SESSION}:2\" ;;
      *) exit 0 ;;
    esac

    # Prompt for optional startup command
    TMPFILE=\$(mktemp /tmp/devopen-cmd-XXXX)
    tmux popup -E -w 40 -h 3 \"TMPFILE=\$TMPFILE ${NEW}\"
    CMD=\$(cat \$TMPFILE); rm -f \$TMPFILE

    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment   -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(tmux show-environment   -t \$SESSION \$EM | cut -d= -f2)
    DIR=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_path}')

    # Create new shelf pane; it lands at slot COUNT-1 (last)
    tmux split-window -h -t \"\$SHELF\" -c \"\$DIR\"
    NEW_SLOT=\$(( COUNT - 1 ))

    # Swap new shelf pane into content, pushing current content to shelf
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${NEW_SLOT}\"

    # Update MAP: old active tab gets NEW_SLOT; new tab gets '-' (active)
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v cur=\"\$CUR\" -v slot=\"\$NEW_SLOT\" \
      'NR==cur+1{print slot; next}{print}' \
      | tr '\n' ':' | sed 's/:\$//')
    NEW_MAP=\"\${NEW_MAP}:-\"

    NEWCOUNT=\$(( COUNT + 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$COUNT    # new tab index = old COUNT
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    [ -n \"\$CMD\" ] && tmux send-keys -t \"\$CONTENT\" \"\$CMD\" C-m
    tmux display-message \"[\$NEWCOUNT/\$NEWCOUNT] new tab\"
  "

  # prefix+X — kill current tab (refuses if it's the last one)
  tmux bind-key -T prefix X run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; CONTENT=\"${SESSION}:0.4\"; SHELF=\"${SESSION}:1\" ;;
      1|2) ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; CONTENT=\"${SESSION}:0.2\"; SHELF=\"${SESSION}:2\" ;;
      *) exit 0 ;;
    esac

    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment   -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(tmux show-environment   -t \$SESSION \$EM | cut -d= -f2)
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0

    # Switch to previous tab first, then kill the shelf pane that now holds CUR
    PREV=\$(( (CUR - 1 + COUNT) % COUNT ))
    PREV_SLOT=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( PREV + 1 ))p\")
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${PREV_SLOT}\"
    tmux kill-pane -t \"\${SHELF}.\${PREV_SLOT}\"

    # Rebuild MAP: remove CUR entry, update slots above the killed one
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v cur=\"\$CUR\" -v prev=\"\$PREV\" -v slot=\"\$PREV_SLOT\" '
      NR == prev+1 { next }
      NR == cur+1  { print "-"; next }
      { print (\$0 != \"-\" && \$0+0 > slot) ? \$0-1 : \$0 }
    ' | tr '\n' ':' | sed 's/:\$//')

    NEWCOUNT=\$(( COUNT - 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$PREV
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    CMD=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_command}')
    tmux display-message \"[\$(( PREV + 1 ))/\$NEWCOUNT] \$CMD\"
  "

  # prefix+G — fzf jump: select any tab or plain pane and focus it
  tmux bind-key -T prefix G run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${JUMP}\"
    SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
    [ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
    case \"\$SYS\" in
      pane)   tmux select-pane -t \"${SESSION}:0.\${IDX}\" ;;
      right)  ${SWITCH} right  \$IDX; tmux select-pane -t \"${SESSION}:0.4\" ;;
      bottom) ${SWITCH} bottom \$IDX; tmux select-pane -t \"${SESSION}:0.2\" ;;
    esac
  "

  # prefix+D — fzf kill: pick and kill any inactive tab
  tmux bind-key -T prefix D run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${KILL}\"
    SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
    [ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0

    if [ \"\$SYS\" = \"right\" ]; then
      ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; SHELF=\"${SESSION}:1\"
    else
      ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; SHELF=\"${SESSION}:2\"
    fi

    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment   -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(tmux show-environment   -t \$SESSION \$EM | cut -d= -f2)
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0

    SLOT=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( IDX + 1 ))p\")
    tmux kill-pane -t \"\${SHELF}.\${SLOT}\"

    # Rebuild MAP: remove IDX entry, update slots above the killed one
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v idx=\"\$IDX\" -v slot=\"\$SLOT\" '
      NR == idx+1 { next }
      { print (\$0 != \"-\" && \$0+0 > slot) ? \$0-1 : \$0 }
    ' | tr '\n' ':' | sed 's/:\$//')

    NEWCOUNT=\$(( COUNT - 1 ))
    NEWCUR=\$(( IDX < CUR ? CUR - 1 : CUR ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$NEWCUR
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux display-message \"Killed \$SYS tab \$(( IDX + 1 )) [\$NEWCOUNT left]\"
  "

  # Alt+1..9 — jump to tab by number (context-aware)
  local i
  for i in 1 2 3 4 5 6 7 8 9; do
    local IDX=$(( i - 1 ))
    tmux bind-key -n "M-$i" run-shell "
      PANE=\$(tmux display-message -p '#{pane_index}')
      case \"\$PANE\" in
        3|4) ${SWITCH} right  ${IDX} ;;
        1|2) ${SWITCH} bottom ${IDX} ;;
        *)   tmux send-keys 'M-$i' ;;
      esac
    "
  done

  # h/← and l/→ — prev/next tab, only when focused on a tab-bar pane (1 or 3)
  # Falls through to send the literal key otherwise (so nvim is unaffected).
  _devopen_bind_nav() {
    local KEY="$1" DIR="$2" OP="$3"
    tmux bind-key -n "$KEY" run-shell "
      PANE=\$(tmux display-message -p '#{pane_index}')
      SESSION=\$(tmux display-message -p '#S')
      case \"\$PANE\" in
        3) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
           CUR=\$(tmux show-environment   -t \$SESSION DEVOPEN_RTAB       | cut -d= -f2)
           ${SWITCH} right \$(( ($OP) % COUNT )) ;;
        1) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
           CUR=\$(tmux show-environment   -t \$SESSION DEVOPEN_BTAB       | cut -d= -f2)
           ${SWITCH} bottom \$(( ($OP) % COUNT )) ;;
        *) tmux send-keys '$KEY' ;;
      esac
    "
  }
  _devopen_bind_nav h    prev "(CUR - 1 + COUNT)"
  _devopen_bind_nav Left prev "(CUR - 1 + COUNT)"
  _devopen_bind_nav l    next "(CUR + 1)"
  _devopen_bind_nav Right next "(CUR + 1)"

  # ---------------------------------------------------------------------------
  # Final setup — return to main window, focus nvim, resize tab-bars to 2 rows
  # ---------------------------------------------------------------------------
  tmux select-window -t "$SESSION:0"
  tmux select-pane   -t "$SESSION:0.0"
  # Resize in background after a short delay to let panes settle
  ( sleep 0.2
    tmux resize-pane -t "$SESSION:0.3" -y 2
    tmux resize-pane -t "$SESSION:0.1" -y 2
  ) &
  tmux attach -t "$SESSION"
}

# =============================================================================
# devclose — tear down the current devopen workspace
#
# Removes all temp scripts and cache files, unbinds all devopen key bindings,
# and kills the tmux session. Must be run from inside the target session.
# =============================================================================
devclose() {
  local SESSION
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  [[ -z "$SESSION" ]] && { echo "devclose: not inside a tmux session"; return 1; }

  echo "devclose: closing '$SESSION'..."

  # Remove all session-scoped temp files
  rm -f /tmp/devopen-${SESSION}-*.sh \
        /tmp/devopen-${SESSION}-*.cache \
        /tmp/devopen-cmd-* \
        /tmp/devopen-sel-*

  # Unbind nav keys
  tmux unbind-key -n h     2>/dev/null
  tmux unbind-key -n l     2>/dev/null
  tmux unbind-key -n Left  2>/dev/null
  tmux unbind-key -n Right 2>/dev/null
  local i
  for i in 1 2 3 4 5 6 7 8 9; do
    tmux unbind-key -n "M-$i" 2>/dev/null
  done

  # Unbind prefix keys
  tmux unbind-key -T prefix T 2>/dev/null
  tmux unbind-key -T prefix N 2>/dev/null
  tmux unbind-key -T prefix X 2>/dev/null
  tmux unbind-key -T prefix G 2>/dev/null
  tmux unbind-key -T prefix D 2>/dev/null

  tmux kill-session -t "$SESSION"
}
