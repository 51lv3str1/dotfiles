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

# ─── TMUX ────────────────────────────────────────────────────
devopen() {
  local FILE="${1:-.}"
  local DIR
  if [ -d "$FILE" ]; then
    DIR=$(realpath "$FILE")
    FILE="."
  else
    DIR=$(realpath "$(dirname "$FILE")")
  fi
  local NAME=$(basename "${1:-.}")
  local SESSION="${NAME}-$(date +%s)"
  for cmd in nvim claude lazygit lazydocker fzf; do
    command -v "$cmd" &>/dev/null || { echo "devopen: missing dependency: $cmd"; return 1; }
  done
  # --- Layout ---
  # ┌─────────────────────┬──────────┐
  # │                     │ [rbar] 3 │  right tab-bar (2 rows, full height)
  # │       nvim          ├──────────┤
  # │       pane 0        │ rcontent │  pane 4 (claude/lazygit/lazydocker, full height)
  # │                     │          │
  # ├─────────────────────┤          │
  # │ [bbar]    pane 1    │          │  bottom tab-bar (nvim-width only)
  # ├─────────────────────┤          │
  # │ bcontent  pane 2    │          │  bottom tab-content (nvim-width only)
  # └─────────────────────┴──────────┘
  tmux new-session -d -s "$SESSION" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"

  # Step 1: right column off pane 0, full height
  # result: pane 0=left full, pane 1=right full
  tmux split-window -h -p 25 -t "$SESSION":0.0 -c "$DIR"

  # Step 2: bottom strip off pane 0 (left/nvim column only)
  # result: pane 0=nvim, pane 1=bottom-left, pane 2=right full
  tmux select-pane -t "$SESSION":0.0
  tmux split-window -v -p 30 -t "$SESSION":0.0 -c "$DIR"

  # Step 3: split bbar off bottom-left pane 1
  # result: pane 0=nvim, pane 1=bbar, pane 2=bcontent, pane 3=right full
  tmux select-pane -t "$SESSION":0.1
  tmux split-window -v -p 90 -t "$SESSION":0.1 -c "$DIR"

  # Step 4: split rbar off right full pane 3
  # result: pane 0=nvim, pane 1=bbar, pane 2=bcontent, pane 3=rbar, pane 4=rcontent
  tmux select-pane -t "$SESSION":0.3
  tmux split-window -v -p 90 -t "$SESSION":0.3 -c "$DIR"

  # Pane map:
  # 0 = nvim
  # 1 = bottom tab-bar      (nvim-width only)
  # 2 = bottom tab-content  (nvim-width only)
  # 3 = right tab-bar       (full height)
  # 4 = right tab-content   (full height) <- claude/lazygit/lazydocker
  tmux send-keys -t "$SESSION":0.0 "nvim \"$FILE\"" Enter
  tmux send-keys -t "$SESSION":0.4 "clear && claude" Enter
  tmux send-keys -t "$SESSION":0.2 "clear && zsh" Enter

  # --- Right shelf: window 1 ---
  tmux new-window -t "$SESSION" -c "$DIR" -n "tabs-right"
  tmux split-window -h -t "$SESSION":1 -c "$DIR"
  tmux send-keys -t "$SESSION":1.0 "clear && lazygit" Enter
  tmux send-keys -t "$SESSION":1.1 "clear && lazydocker" Enter
  tmux set-environment -t "$SESSION" DEVOPEN_RTAB 0
  tmux set-environment -t "$SESSION" DEVOPEN_RTAB_COUNT 3
  tmux set-environment -t "$SESSION" DEVOPEN_RMAP "-:0:1"

  # --- Bottom shelf: window 2 ---
  tmux new-window -t "$SESSION" -c "$DIR" -n "tabs-bottom"
  tmux send-keys -t "$SESSION":2.0 'clear' Enter
  tmux set-environment -t "$SESSION" DEVOPEN_BTAB 0
  tmux set-environment -t "$SESSION" DEVOPEN_BTAB_COUNT 1
  tmux set-environment -t "$SESSION" DEVOPEN_BMAP "-"

  # --- Right tab-bar renderer (pane 3) ---
  local RTAGTMP="/tmp/devopen-rtags-${SESSION}.sh"
  local RTABCACHE="/tmp/devopen-rtabs-${SESSION}.cache"
  cat > "$RTAGTMP" << RTAGEOF
#!/bin/sh
SESSION="${SESSION}"
TABCACHE="${RTABCACHE}"
RESET="\033[0m"
A_TEXT="\033[38;5;141m"
I_TEXT="\033[38;5;248m"
SEP="  "
while tmux has-session -t "\$SESSION" 2>/dev/null; do
  COUNT=\$(tmux show-environment -t "\$SESSION" DEVOPEN_RTAB_COUNT 2>/dev/null | cut -d= -f2)
  CUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_RTAB 2>/dev/null | cut -d= -f2)
  MAP=\$(tmux show-environment -t "\$SESSION" DEVOPEN_RMAP 2>/dev/null | cut -d= -f2)
  [ -z "\$COUNT" ] && sleep 0.1 && continue
  LINE=""
  CACHE=""
  for i in \$(seq 0 \$(( COUNT - 1 ))); do
    NUM=\$(( i + 1 ))
    if [ "\$i" = "\$CUR" ]; then
      CMD=\$(tmux display-message -p -t "\${SESSION}:0.4" "#{pane_current_command}" 2>/dev/null)
      CMD=\$(echo "\$CMD" | cut -c1-8)
      LINE="\${LINE}\${A_TEXT}● \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i} * \${CMD}\n"
    else
      SHELF_IDX=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( i + 1 ))p")
      CMD=\$(tmux display-message -p -t "\${SESSION}:1.\${SHELF_IDX}" "#{pane_current_command}" 2>/dev/null)
      CMD=\$(echo "\$CMD" | cut -c1-8)
      LINE="\${LINE}\${I_TEXT}○ \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i}   \${CMD}\n"
    fi
  done
  printf "\033[H\033[2J"
  printf " \${LINE}\n"
  printf "\${CACHE}" > "\$TABCACHE"
  sleep 0.1
done
RTAGEOF
  chmod +x "$RTAGTMP"
  tmux send-keys -t "$SESSION":0.3 "$RTAGTMP" Enter

  # --- Bottom tab-bar renderer (pane 1) ---
  local BTAGTMP="/tmp/devopen-btags-${SESSION}.sh"
  local BTABCACHE="/tmp/devopen-btabs-${SESSION}.cache"
  cat > "$BTAGTMP" << BTAGEOF
#!/bin/sh
SESSION="${SESSION}"
TABCACHE="${BTABCACHE}"
RESET="\033[0m"
A_TEXT="\033[38;5;141m"
I_TEXT="\033[38;5;248m"
SEP="  "
while tmux has-session -t "\$SESSION" 2>/dev/null; do
  COUNT=\$(tmux show-environment -t "\$SESSION" DEVOPEN_BTAB_COUNT 2>/dev/null | cut -d= -f2)
  CUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_BTAB 2>/dev/null | cut -d= -f2)
  MAP=\$(tmux show-environment -t "\$SESSION" DEVOPEN_BMAP 2>/dev/null | cut -d= -f2)
  [ -z "\$COUNT" ] && sleep 0.1 && continue
  LINE=""
  CACHE=""
  for i in \$(seq 0 \$(( COUNT - 1 ))); do
    NUM=\$(( i + 1 ))
    if [ "\$i" = "\$CUR" ]; then
      CMD=\$(tmux display-message -p -t "\${SESSION}:0.2" "#{pane_current_command}" 2>/dev/null)
      CMD=\$(echo "\$CMD" | cut -c1-8)
      LINE="\${LINE}\${A_TEXT}● \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i} * \${CMD}\n"
    else
      SHELF_IDX=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( i + 1 ))p")
      CMD=\$(tmux display-message -p -t "\${SESSION}:2.\${SHELF_IDX}" "#{pane_current_command}" 2>/dev/null)
      CMD=\$(echo "\$CMD" | cut -c1-8)
      LINE="\${LINE}\${I_TEXT}○ \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i}   \${CMD}\n"
    fi
  done
  printf "\033[H\033[2J"
  printf " \${LINE}\n"
  printf "\${CACHE}" > "\$TABCACHE"
  sleep 0.1
done
BTAGEOF
  chmod +x "$BTAGTMP"
  tmux send-keys -t "$SESSION":0.1 "$BTAGTMP" Enter

  # --- Shared switch script ---
  local SWITCH_SCRIPT="/tmp/devopen-switch-${SESSION}.sh"
  cat > "$SWITCH_SCRIPT" << SWITCHEOF
#!/bin/sh
SESSION="${SESSION}"
SYSTEM="\$1"
IDX="\$2"
if [ "\$SYSTEM" = "right" ]; then
  ENV_TAB="DEVOPEN_RTAB"
  ENV_COUNT="DEVOPEN_RTAB_COUNT"
  ENV_MAP="DEVOPEN_RMAP"
  CONTENT_PANE="\${SESSION}:0.4"
  SHELF_WIN="\${SESSION}:1"
else
  ENV_TAB="DEVOPEN_BTAB"
  ENV_COUNT="DEVOPEN_BTAB_COUNT"
  ENV_MAP="DEVOPEN_BMAP"
  CONTENT_PANE="\${SESSION}:0.2"
  SHELF_WIN="\${SESSION}:2"
fi
COUNT=\$(tmux show-environment -t "\$SESSION" "\$ENV_COUNT" | cut -d= -f2)
CUR=\$(tmux show-environment -t "\$SESSION" "\$ENV_TAB" | cut -d= -f2)
[ -z "\$IDX" ] && exit 0
[ "\$IDX" -ge "\$COUNT" ] && tmux display-message -t "\$SESSION" "No tab \$(( IDX + 1 ))" && exit 0
[ "\$IDX" = "\$CUR" ] && exit 0
# MAP is a colon-separated list of shelf slots indexed by tab number.
# e.g. MAP="1:0:2" means tab0->shelf1, tab1->shelf0, tab2->shelf2
# The active tab has no shelf slot (it's in CONTENT_PANE); its MAP entry is "-"
MAP=\$(tmux show-environment -t "\$SESSION" "\$ENV_MAP" 2>/dev/null | cut -d= -f2)
TARGET_SHELF=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( IDX + 1 ))p")
CUR_SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( CUR + 1 ))p")
# Swap target tab into content pane
tmux swap-pane -s "\$CONTENT_PANE" -t "\${SHELF_WIN}.\${TARGET_SHELF}"
# Update map: active tab now occupies TARGET_SHELF slot, target tab is active (-)
NEW_MAP=\$(echo "\$MAP" | tr ':' '\n' | awk -v cur="\$CUR" -v idx="\$IDX" -v slot="\$TARGET_SHELF" '
  NR == cur+1 { print slot; next }
  NR == idx+1 { print "-"; next }
  { print }
' | tr '\n' ':' | sed 's/:$//')
tmux set-environment -t "\$SESSION" "\$ENV_MAP" "\$NEW_MAP"
tmux set-environment -t "\$SESSION" "\$ENV_TAB" "\$IDX"
tmux select-pane -t "\$CONTENT_PANE"
CMD=\$(tmux display-message -p -t "\$CONTENT_PANE" "#{pane_current_command}")
tmux display-message -t "\$SESSION" "[\$(( IDX + 1 ))/\$COUNT] \$CMD"
SWITCHEOF
  chmod +x "$SWITCH_SCRIPT"

  # --- New tab script ---
  local NEW_SCRIPT="/tmp/devopen-new-${SESSION}.sh"
  cat > "$NEW_SCRIPT" << NEWEOF
#!/bin/sh
printf "command > "
read -r CMD
printf "%s\n" "\$CMD" > "\$TMPFILE"
NEWEOF
  chmod +x "$NEW_SCRIPT"

  # --- Jump script (unified: shows all tabs from both panes) ---
  local JUMP_SCRIPT="/tmp/devopen-jump-${SESSION}.sh"
  cat > "$JUMP_SCRIPT" << JUMPEOF
#!/bin/sh
RTABCACHE="${RTABCACHE}"
BTABCACHE="${BTABCACHE}"
SESSION="${SESSION}"
# Build unified list: "system:idx marker cmd"
COMBINED=""
RCUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_RTAB 2>/dev/null | cut -d= -f2)
BCUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_BTAB 2>/dev/null | cut -d= -f2)
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  NUM=\$(( IDX + 1 ))
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\${NUM} \${REST}\n"
done < "\$RTABCACHE"
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  NUM=\$(( IDX + 1 ))
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}bottom:\${IDX} bottom:\${NUM} \${REST}\n"
done < "\$BTABCACHE"
SELECTED=\$(printf "%b" "\$COMBINED" | fzf \
  --prompt="jump > " \
  --height=100% \
  --layout=reverse \
  --border=none \
  --with-nth=2.. \
  --color="prompt:#89b4fa,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#a6e3a1" \
  --preview-window=hidden)
[ -z "\$SELECTED" ] && printf "\n" > "\$TMPFILE" && exit 0
SYS=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f1)
IDX=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f2)
printf "%s\n%s\n" "\$SYS" "\$IDX" > "\$TMPFILE"
JUMPEOF
  chmod +x "$JUMP_SCRIPT"

  # --- Kill script (unified: shows all tabs from both panes, excludes active ones) ---
  local KILL_SCRIPT="/tmp/devopen-kill-${SESSION}.sh"
  cat > "$KILL_SCRIPT" << KILLEOF
#!/bin/sh
RTABCACHE="${RTABCACHE}"
BTABCACHE="${BTABCACHE}"
SESSION="${SESSION}"
RCUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_RTAB 2>/dev/null | cut -d= -f2)
BCUR=\$(tmux show-environment -t "\$SESSION" DEVOPEN_BTAB 2>/dev/null | cut -d= -f2)
# Build unified list excluding active tabs (marked with *), display 1-based
COMBINED=""
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  echo "\$line" | grep -q " \* " && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  NUM=\$(( IDX + 1 ))
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\${NUM} \${REST}\n"
done < "\$RTABCACHE"
while IFS= read -r line; do
  [ -z "\$line" ] && continue
  echo "\$line" | grep -q " \* " && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  NUM=\$(( IDX + 1 ))
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}bottom:\${IDX} bottom:\${NUM} \${REST}\n"
done < "\$BTABCACHE"
[ -z "\$COMBINED" ] && printf "\n" > "\$TMPFILE" && exit 0
SELECTED=\$(printf "%b" "\$COMBINED" | fzf \
  --prompt="kill > " \
  --height=100% \
  --layout=reverse \
  --border=none \
  --with-nth=2.. \
  --color="prompt:#f38ba8,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#f38ba8" \
  --preview-window=hidden)
[ -z "\$SELECTED" ] && printf "\n" > "\$TMPFILE" && exit 0
SYS=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f1)
IDX=\$(echo "\$SELECTED" | awk '{print \$1}' | cut -d: -f2)
printf "%s\n%s\n" "\$SYS" "\$IDX" > "\$TMPFILE"
KILLEOF
  chmod +x "$KILL_SCRIPT"

  local SWITCH="${SWITCH_SCRIPT}"
  local NEW="${NEW_SCRIPT}"
  local JUMP="${JUMP_SCRIPT}"
  local KILL="${KILL_SCRIPT}"

  # --- prefix+T: cycle next tab ---
  tmux bind-key -T prefix T run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) SYS=right;  ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT ;;
      1|2) SYS=bottom; ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT ;;
      *) exit 0 ;;
    esac
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    NEXT=\$(( (CUR + 1) % COUNT ))
    ${SWITCH} \$SYS \$NEXT
  "

  # --- prefix+N: new tab ---
  tmux bind-key -T prefix N run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) EC=DEVOPEN_RTAB_COUNT; ET=DEVOPEN_RTAB; EM=DEVOPEN_RMAP; SYS=right;  CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\" ;;
      1|2) EC=DEVOPEN_BTAB_COUNT; ET=DEVOPEN_BTAB; EM=DEVOPEN_BMAP; SYS=bottom; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\" ;;
      *) exit 0 ;;
    esac
    TMPFILE=\$(mktemp /tmp/devopen-cmd-XXXX)
    tmux popup -E -w 40 -h 3 \"TMPFILE=\$TMPFILE ${NEW}\"
    CMD=\$(cat \$TMPFILE); rm -f \$TMPFILE
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    MAP=\$(tmux show-environment -t \$SESSION \$EM | cut -d= -f2)
    DIR=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_path}')
    tmux split-window -t \"\$SHELF\" -h -c \"\$DIR\"
    NEW_SHELF_SLOT=\$(( COUNT - 1 ))
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${NEW_SHELF_SLOT}\"
    NEWCOUNT=\$(( COUNT + 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$COUNT
    NEW_MAP=\"\${MAP}:\${NEW_SHELF_SLOT}\"
    CUR_IDX=\$(tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    NEW_MAP=\$(echo \"\$NEW_MAP\" | tr ':' '\n' | awk -v cur=\"\$CUR_IDX\" -v slot=\"\$NEW_SHELF_SLOT\" 'NR==cur+1{print slot; next}{print}' | tr '\n' ':' | sed 's/:\$//')
    NEW_MAP=\"\${NEW_MAP}:-\"
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    [ -n \"\$CMD\" ] && tmux send-keys -t \"\$CONTENT\" \"\$CMD\" C-m
    tmux display-message \"[\$NEWCOUNT/\$NEWCOUNT] zsh\"
  "

  # --- prefix+X: kill current tab ---
  tmux bind-key -T prefix X run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\" ;;
      1|2) ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\" ;;
      *) exit 0 ;;
    esac
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0
    MAP=\$(tmux show-environment -t \$SESSION \$EM | cut -d= -f2)
    PREV=\$(( (CUR - 1 + COUNT) % COUNT ))
    PREV_SHELF=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( PREV + 1 ))p\")
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${PREV_SHELF}\"
    tmux kill-pane -t \"\${SHELF}.\${PREV_SHELF}\"
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk -v cur=\"\$CUR\" -v prev=\"\$PREV\" -v slot=\"\$PREV_SHELF\" '
      NR == prev+1 { next }
      NR == cur+1  { print "-"; next }
      { val=\$0+0; if (val > slot) val--; print val }
    ' | tr '\n' ':' | sed 's/:\$//')
    NEWCOUNT=\$(( COUNT - 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$PREV
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    CMD=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_command}')
    tmux display-message \"[\$(( PREV + 1 ))/\$NEWCOUNT] \$CMD\"
  "

  # --- prefix+G: fzf jump (unified, all tabs) ---
  tmux bind-key -T prefix G run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${JUMP}\"
    SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
    [ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
    ${SWITCH} \$SYS \$IDX
    if [ \"\$SYS\" = \"right\" ]; then
      tmux select-pane -t \"\${SESSION}:0.4\"
    else
      tmux select-pane -t \"\${SESSION}:0.2\"
    fi
  "

  # --- prefix+D: fzf kill (unified, all tabs, excludes active) ---
  tmux bind-key -T prefix D run-shell "
    SESSION=\$(tmux display-message -p '#S')
    RCOUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
    BCOUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
    TOTAL=\$(( RCOUNT + BCOUNT ))
    [ \$TOTAL -le 2 ] && tmux display-message 'Cannot close last tab in each pane' && exit 0
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${KILL}\"
    SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
    [ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
    if [ \"\$SYS\" = \"right\" ]; then
      ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\"
    else
      ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\"
    fi
    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    [ \$COUNT -le 1 ] && tmux display-message 'Cannot close last tab in this pane' && exit 0
    CUR=\$(tmux show-environment -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(tmux show-environment -t \$SESSION \$EM | cut -d= -f2)
    SHELF_IDX=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( IDX + 1 ))p\")
    tmux kill-pane -t \"\${SHELF}.\${SHELF_IDX}\"
    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk -v idx=\"\$IDX\" -v slot=\"\$SHELF_IDX\" '
      NR == idx+1 { next }
      { val=\$0; if (val != \"-\" && val+0 > slot) val=val-1; print val }
    ' | tr '\n' ':' | sed 's/:\$//')
    NEWCOUNT=\$(( COUNT - 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    NEWCUR=\$CUR
    [ \"\$IDX\" -lt \"\$CUR\" ] && NEWCUR=\$(( CUR - 1 ))
    tmux set-environment -t \$SESSION \$ET \$NEWCUR
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux display-message \"Killed \$SYS tab \$(( IDX + 1 )) [\$NEWCOUNT left]\"
  "

  # --- Alt+1-9: jump by number ---
  for i in 1 2 3 4 5 6 7 8 9; do
    local IDX=$(( i - 1 ))
    tmux bind-key -n "M-$i" run-shell "
      PANE=\$(tmux display-message -p '#{pane_index}')
      case \"\$PANE\" in
        3|4) ${SWITCH} right ${IDX} ;;
        1|2) ${SWITCH} bottom ${IDX} ;;
        *)   tmux send-keys 'M-$i' ;;
      esac
    "
  done

  # --- h/← and l/→: only on tab-bar panes 3 and 1 ---
  tmux bind-key -n h run-shell "
    PANE=\$(tmux display-message -p '#{pane_index}')
    SESSION=\$(tmux display-message -p '#S')
    case \"\$PANE\" in
      3) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB | cut -d= -f2)
         ${SWITCH} right \$(( (CUR - 1 + COUNT) % COUNT )) ;;
      1) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB | cut -d= -f2)
         ${SWITCH} bottom \$(( (CUR - 1 + COUNT) % COUNT )) ;;
      *) tmux send-keys 'h' ;;
    esac
  "
  tmux bind-key -n l run-shell "
    PANE=\$(tmux display-message -p '#{pane_index}')
    SESSION=\$(tmux display-message -p '#S')
    case \"\$PANE\" in
      3) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB | cut -d= -f2)
         ${SWITCH} right \$(( (CUR + 1) % COUNT )) ;;
      1) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB | cut -d= -f2)
         ${SWITCH} bottom \$(( (CUR + 1) % COUNT )) ;;
      *) tmux send-keys 'l' ;;
    esac
  "
  tmux bind-key -n Left run-shell "
    PANE=\$(tmux display-message -p '#{pane_index}')
    SESSION=\$(tmux display-message -p '#S')
    case \"\$PANE\" in
      3) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB | cut -d= -f2)
         ${SWITCH} right \$(( (CUR - 1 + COUNT) % COUNT )) ;;
      1) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB | cut -d= -f2)
         ${SWITCH} bottom \$(( (CUR - 1 + COUNT) % COUNT )) ;;
      *) tmux send-keys 'Left' ;;
    esac
  "
  tmux bind-key -n Right run-shell "
    PANE=\$(tmux display-message -p '#{pane_index}')
    SESSION=\$(tmux display-message -p '#S')
    case \"\$PANE\" in
      3) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_RTAB | cut -d= -f2)
         ${SWITCH} right \$(( (CUR + 1) % COUNT )) ;;
      1) COUNT=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB_COUNT | cut -d= -f2)
         CUR=\$(tmux show-environment -t \$SESSION DEVOPEN_BTAB | cut -d= -f2)
         ${SWITCH} bottom \$(( (CUR + 1) % COUNT )) ;;
      *) tmux send-keys 'Right' ;;
    esac
  "

  tmux select-window -t "$SESSION:0"
  tmux select-pane -t "$SESSION":0.0
  (sleep 0.2 && \
    tmux resize-pane -t "$SESSION":0.3 -y 2 && \
    tmux resize-pane -t "$SESSION":0.1 -y 2) &
  tmux attach -t "$SESSION"
}

devclose() {
  local SESSION
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  if [ -z "$SESSION" ]; then
    echo "devclose: not inside a tmux session"
    return 1
  fi
  echo "devclose: closing session '$SESSION' and cleaning up..."
  rm -f \
    "/tmp/devopen-rtags-${SESSION}.sh" \
    "/tmp/devopen-btags-${SESSION}.sh" \
    "/tmp/devopen-rtabs-${SESSION}.cache" \
    "/tmp/devopen-btabs-${SESSION}.cache" \
    "/tmp/devopen-new-${SESSION}.sh" \
    "/tmp/devopen-jump-${SESSION}.sh" \
    "/tmp/devopen-kill-${SESSION}.sh" \
    "/tmp/devopen-switch-${SESSION}.sh" \
    "/tmp/devopen-detect-${SESSION}.sh"
  rm -f /tmp/devopen-cmd-* /tmp/devopen-sel-*
  tmux unbind-key -n h     2>/dev/null
  tmux unbind-key -n l     2>/dev/null
  tmux unbind-key -n Left  2>/dev/null
  tmux unbind-key -n Right 2>/dev/null
  for i in 1 2 3 4 5 6 7 8 9; do
    tmux unbind-key -n "M-$i" 2>/dev/null
  done
  tmux unbind-key -T prefix T 2>/dev/null
  tmux unbind-key -T prefix N 2>/dev/null
  tmux unbind-key -T prefix X 2>/dev/null
  tmux unbind-key -T prefix G 2>/dev/null
  tmux unbind-key -T prefix D 2>/dev/null
  tmux kill-session -t "$SESSION"
}
