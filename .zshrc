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

# ─── TMUX ─────────────────────────────────────────────────────
# Layout:
# ┌─────────────────────────┬────────────┐
# │                         │            │
# │         nvim            │   claude   │
# │         pane 0          │   pane 1   │
# │          75%            │    25%     │
# ├─────────┬───────────────┼────────────┤
# │         │   tab-tags    │            │
# │  lazy   │   pane 3 10%  │  lazygit   │
# │ docker  ├───────────────┤   pane 5   │
# │ pane 2  │  tab-content  │    25%     │
# │   25%   │   pane 4 90%  │            │
# └─────────┴───────────────┴────────────┘
devopen() {
  local session_name="${1:-dev}"
  local dir="${2:-$PWD}"

  if [[ -n "$TMUX" ]]; then
    tmux split-window -v -p 25
    tmux select-pane -t 0
    tmux split-window -h -p 25
    tmux select-pane -t 2
    tmux split-window -h -p 25
    tmux select-pane -t 2
    tmux split-window -h -p 64
    tmux resize-pane -t 2 -x 42
    tmux select-pane -t 3
    tmux split-window -v -p 90
    # launch tools
    tmux send-keys -t 0 "nvim" Enter
    tmux send-keys -t 1 "claude" Enter
    tmux send-keys -t 2 "lazydocker" Enter
    tmux send-keys -t 4 "lazygit" Enter
    tmux select-pane -t 0
    return
  fi

  tmux new-session -d -s "$session_name" -c "$dir" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -v -p 25 -t "$session_name"
  tmux select-pane -t "$session_name":0.0
  tmux split-window -h -p 25 -t "$session_name"
  tmux select-pane -t "$session_name":0.2
  tmux split-window -h -p 25 -t "$session_name"
  tmux select-pane -t "$session_name":0.2
  tmux split-window -h -p 64 -t "$session_name"
  tmux resize-pane -t "$session_name":0.2 -x 42
  tmux select-pane -t "$session_name":0.3
  tmux split-window -v -p 90 -t "$session_name"
  # launch tools
  tmux send-keys -t "$session_name":0.0 "nvim" Enter
  tmux send-keys -t "$session_name":0.1 "claude" Enter
  tmux send-keys -t "$session_name":0.2 "lazydocker" Enter
  tmux send-keys -t "$session_name":0.5 "lazygit" Enter
  tmux select-pane -t "$session_name":0.0
  tmux attach-session -t "$session_name"
}
