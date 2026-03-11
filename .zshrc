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
# now — compact event dashboard (today's calendar events via khal)
# =============================================================================
#
# Displays today's events from khal in a compact single-column format.
# Designed to run inside the devopen workspace dash pane (dcont=6) on a loop,
# refreshing every 60 seconds. Can also be called standalone: `now`
#
# Calendar color coding (matches khal calendar names):
#   google   → blue    familia → pink    festivos → green
#   daruma   → orange  allaria → cyan
#
# Dependencies: khal
# =============================================================================

now() {
  local ESC=$'\033'
  local reset="${ESC}[0m"
  local bold="${ESC}[1m"
  local dim="${ESC}[2m"
  local italic="${ESC}[3m"
  local gray="${ESC}[38;5;245m"
  local muted="${ESC}[38;5;240m"
  local white="${ESC}[97m"

  # Calendar-specific colors and icons
  local -A cal_color=(
    [google]="${ESC}[38;5;75m"
    [familia]="${ESC}[38;5;213m"
    [festivos]="${ESC}[38;5;120m"
    [daruma]="${ESC}[38;5;215m"
    [allaria]="${ESC}[38;5;159m"
  )
  local -A cal_icon=(
    [google]="󰊫"
    [familia]="󰉌"
    [festivos]="󰃦"
    [daruma]="󰃯"
    [allaria]="󰃯"
  )
  local default_color="$white"
  local default_icon="󰃯"

  local now_int=$(date "+%H%M")

  # Events from khal
  local raw_events
  raw_events=$(khal list today --format "{start-time}|{end-time}|{title}|{calendar}" 2>/dev/null)

  if [[ -z "$raw_events" ]]; then
    printf "  ${muted}${italic}no events today${reset}\n\n"
    return
  fi

  local -A seen
  local printed=0
  while IFS='|' read -r start end title calendar; do
    # Skip header lines khal emits (day names)
    [[ "$start" =~ ^(Today|Tomorrow|Mon|Tue|Wed|Thu|Fri|Sat|Sun|Lun|Mar|Mie|Jue|Vie|Sab|Dom) ]] && continue
    [[ -z "$title" ]] && continue
    local key="${start}|${title}"
    [[ -n "${seen[$key]}" ]] && continue
    seen[$key]=1

    local color="${cal_color[$calendar]:-$default_color}"
    local icon="${cal_icon[$calendar]:-$default_icon}"
    local cal_label="${calendar:-?}"

    if [[ -z "$start" ]]; then
      # All-day event
      printf " %s%s${reset} ${gray}%s${reset} ${dim}all day${reset} ${bold}${white}%s${reset}\n" \
        "$color" "$icon" "$cal_label" "$title"
    else
      local start_int=${start//:/}
      local end_int=${end//:/}
      local time_style="" title_style="$white"

      # Dim past events; full brightness for ongoing ones
      if (( start_int < now_int )); then
        time_style="$dim"; title_style="$dim"
      fi
      if (( start_int <= now_int && now_int <= end_int )); then
        time_style=""; title_style="$white"
      fi

      printf " %s%s${reset} ${gray}%s${reset} %s%s${bold}%s${reset}%s/%s${reset} %s%s${reset}\n" \
        "$color" "$icon" "$cal_label" \
        "$time_style" "$color" "$start" "$time_style" "$end" \
        "$title_style" "$title"
    fi
    (( printed++ ))
  done <<< "$raw_events"

  [[ $printed -eq 0 ]] && printf " ${muted}${italic}no events today${reset}\n"
  printf "\n"
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
#   │                     │  rbar  3 │  right tab-bar     (2 rows)
#   │       nvim  0       ├──────────┤
#   │                     │ rcont  4 │  right tab-content (claude/lazygit/lazydocker)
#   ├─────────────────────┼──────────┤
#   │  bbar  1            │  dbar  5 │  dash tab-bar      (2 rows)
#   ├─────────────────────┼──────────┤
#   │  bcont 2            │ dcont  6 │  dash content      (now dashboard)
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
#   The dash panel (panes 5+6) has no tab system — it runs `now` on a loop.
#
# COLLAPSE SYSTEM
#   prefix+C is context-aware. Tag panes (1=bbar, 3=rbar, 5=dbar) are always
#   visible and never collapse. When the active pane is a tag, its paired
#   content pane collapses/uncollapses instead. Tag panes never resize.
#
#   Collapsible panes and their axis:
#     0 (nvim)   → width  (-x), collapses to 1 col
#     2 (bcont)  → height (-y), collapses to 1 row  — tag: 1 (bbar)
#     4 (rcont)  → height (-y), collapses to 1 row  — tag: 3 (rbar)
#     6 (dcont)  → height (-y), collapses to 1 row  — tag: 5 (dbar)
#
#   NOTE: tmux does not support resizing a pane to 0. Minimum is 1.
#   Collapsed panes are resized to 1 (effectively invisible) so that their
#   neighbour tag pane remains stable and visible at all times.
#
# TMUX ENVIRONMENT VARIABLES (per session)
#   DEVOPEN_RTAB        0-based index of the currently active right tab
#   DEVOPEN_RTAB_COUNT  total number of right tabs
#   DEVOPEN_RMAP        position map for right tabs
#   DEVOPEN_BTAB        0-based index of the currently active bottom tab
#   DEVOPEN_BTAB_COUNT  total number of bottom tabs
#   DEVOPEN_BMAP        position map for bottom tabs
#   DEVOPEN_COLLAPSED_N 1/0 collapsed state for pane N (0, 2, 4, 6)
#   DEVOPEN_SIZE_N      saved size (width or height) for pane N before collapse
#
# KEY BINDINGS
#   prefix+T        cycle to next tab (context-aware: right or bottom)
#   prefix+N        open a new tab with optional command prompt
#   prefix+X        kill the current tab (refuses if last tab)
#   prefix+C        collapse/uncollapse current pane (context-aware, see above)
#   prefix+G        fzf picker — jump to any tab or plain pane; focuses it
#   prefix+D        fzf picker — kill any inactive tab
#   h / ← / l / →  prev/next tab (only active on tab-bar panes 1 and 3)
#   Alt+1..9        jump to tab N by number (context-aware)
#
# DEPENDENCIES: nvim, claude, lazygit, lazydocker, fzf, khal, vdirsyncer
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
  for dep in nvim claude lazygit lazydocker fzf khal vdirsyncer; do
    command -v "$dep" &>/dev/null || { echo "devopen: missing dependency: $dep"; return 1; }
  done

  # ---------------------------------------------------------------------------
  # Temp file paths — all namespaced by SESSION to support concurrent workspaces
  # ---------------------------------------------------------------------------
  local TMP="/tmp/devopen-${SESSION}"
  local RBAR_SCRIPT="${TMP}-rbar.sh"       # right tab-bar renderer
  local BBAR_SCRIPT="${TMP}-bbar.sh"       # bottom tab-bar renderer
  local DBAR_SCRIPT="${TMP}-dbar.sh"       # dash bar renderer (static label)
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
  # Target (pane indices after all splits):
  #   0 = nvim        (left, tall)
  #   1 = bbar        (bottom-left, 2 rows)
  #   2 = bcont       (bottom-left content)
  #   3 = rbar        (top-right, 2 rows)
  #   4 = rcont       (top-right content)
  #   5 = dbar        (bottom-right, 2 rows)
  #   6 = dcont       (bottom-right content — now dashboard)
  #
  # Split sequence:
  #   s1: pane 0 → right column full height     (0=left, 1=right)
  #   s2: pane 0 → bottom-left strip            (0=nvim, 1=bot-left, 2=right)
  #   s3: pane 1 → bbar + bcont                 (1=bbar, 2=bcont, 3=right)
  #   s4: pane 3 → top-right + bottom-right     (3=top-right, 4=bot-right)
  #   s5: pane 3 → rbar + rcont                 (3=rbar, 4=rcont, 5=bot-right)
  #   s6: pane 5 → dbar + dcont                 (5=dbar, 6=dcont)
  # ---------------------------------------------------------------------------
  tmux new-session -d -s "$SESSION" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -h -p 25 -t "$SESSION":0.0 -c "$DIR"   # s1 → 0=left,  1=right
  tmux select-pane  -t "$SESSION":0.0
  tmux split-window -v -p 30 -t "$SESSION":0.0 -c "$DIR"   # s2 → 0=nvim,  1=bot-left, 2=right
  tmux select-pane  -t "$SESSION":0.1
  tmux split-window -v -p 90 -t "$SESSION":0.1 -c "$DIR"   # s3 → 1=bbar,  2=bcont, 3=right
  tmux select-pane  -t "$SESSION":0.3
  tmux split-window -v -p 30 -t "$SESSION":0.3 -c "$DIR"   # s4 → 3=top-r, 4=bot-r
  tmux select-pane  -t "$SESSION":0.3
  tmux split-window -v -p 90 -t "$SESSION":0.3 -c "$DIR"   # s5 → 3=rbar,  4=rcont, 5=bot-r
  tmux select-pane  -t "$SESSION":0.5
  tmux split-window -v -p 90 -t "$SESSION":0.5 -c "$DIR"   # s6 → 5=dbar,  6=dcont

  # Launch initial programs into their panes
  tmux send-keys -t "$SESSION":0.0 "nvim \"$FILE\"" Enter
  tmux send-keys -t "$SESSION":0.4 "clear && claude" Enter
  tmux send-keys -t "$SESSION":0.2 "clear && zsh" Enter
  tmux send-keys -t "$SESSION":0.6 "while true; do clear && now; sleep 60; done" Enter

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
  # Collapse state — one pair per collapsible pane (0=nvim, 2=bcont, 4=rcont, 6=dcont)
  # SIZE stores width for pane 0, height for panes 2/4/6.
  # Tag panes (1=bbar, 3=rbar, 5=dbar) are always visible and have no state.
  # pane 6 (dcont) starts collapsed; all others start expanded.
  # ---------------------------------------------------------------------------
  tmux set-environment -t "$SESSION" DEVOPEN_COLLAPSED_0 0
  tmux set-environment -t "$SESSION" DEVOPEN_SIZE_0      ""
  tmux set-environment -t "$SESSION" DEVOPEN_COLLAPSED_2 0
  tmux set-environment -t "$SESSION" DEVOPEN_SIZE_2      ""
  tmux set-environment -t "$SESSION" DEVOPEN_COLLAPSED_4 0
  tmux set-environment -t "$SESSION" DEVOPEN_SIZE_4      ""
  tmux set-environment -t "$SESSION" DEVOPEN_COLLAPSED_6 1
  tmux set-environment -t "$SESSION" DEVOPEN_SIZE_6      ""

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

    local ESC=$'\033'
    cat > "$SCRIPT" << EOF
#!/bin/sh
SESSION="${SESSION}"
TABCACHE="${TABCACHE}"
RESET="${ESC}[0m"
ACTIVE="${ESC}[38;5;141m"    # purple — active tab label
INACTIVE="${ESC}[38;5;248m"  # grey   — inactive tab label
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
      CMD=\$(tmux display-message -p -t "${CONTENT_PANE}" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${ACTIVE}● \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i} * \${CMD}\n"
    else
      SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( i + 1 ))p")
      CMD=\$(tmux display-message -p -t "${SHELF_WIN}.\${SLOT}" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
      LINE="\${LINE}\${INACTIVE}○ \${NUM}:\${CMD}\${RESET}\${SEP}"
      CACHE="\${CACHE}\${i}   \${CMD}\n"
    fi
  done

  printf "\033[1;1H\033[K %b\033[K" "\$LINE"
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
  # Dash bar renderer (pane 5) — shows "● 1:calendar" label.
  # Redraws every 1s so it recovers instantly after a resize.
  # Polls khal every 30s to check if any event ends within 5 minutes;
  # appends 󰃯 in orange when so.
  # ---------------------------------------------------------------------------
  local ESC_D=$'\033'
  cat > "$DBAR_SCRIPT" << EOF
#!/bin/bash
SESSION="${SESSION}"
ACTIVE="${ESC_D}[38;5;141m"
RESET="${ESC_D}[0m"

SOON=""
LAST_POLL=0

while tmux has-session -t "\$SESSION" 2>/dev/null; do
  NOW_S=\$(date "+%s")
  NOW=\$(date "+%H%M")

  if (( NOW_S - LAST_POLL >= 30 )); then
    LAST_POLL=\$NOW_S
    SOON=""
    while IFS='|' read -r start end title rest; do
      [ -z "\$end" ] && continue
      END_INT=\$(echo "\$end" | tr -d ':')
      echo "\$END_INT" | grep -qE '^[0-9]{4}$' || continue
      DIFF=\$(( END_INT - NOW ))
      if [ "\$DIFF" -ge 0 ] && [ "\$DIFF" -le 5 ]; then
        SOON=" ${ESC_D}[38;5;215m󰃯${ESC_D}[0m"
        break
      fi
    done <<< "\$(khal list today --format '{start-time}|{end-time}|{title}|{calendar}' 2>/dev/null)"
  fi

  printf "\r%s● 1:calendar%s%s\033[K" "\$ACTIVE" "\$RESET" "\$SOON"
  sleep 1
done
EOF
  chmod +x "$DBAR_SCRIPT"
  tmux send-keys -t "$SESSION":0.5 "$DBAR_SCRIPT" Enter

  # ---------------------------------------------------------------------------
  # Switch script — moves a logical tab into the content pane.
  # ---------------------------------------------------------------------------
  cat > "$SWITCH_SCRIPT" << EOF
#!/bin/sh
SESSION="${SESSION}"
SYSTEM="\$1"
IDX="\$2"

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

TARGET_SLOT=\$(echo "\$MAP" | tr ':' '\n' | sed -n "\$(( IDX + 1 ))p")
tmux swap-pane -s "\$CONTENT" -t "\${SHELF}.\${TARGET_SLOT}"

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
  # New-tab prompt script
  # ---------------------------------------------------------------------------
  cat > "$NEW_SCRIPT" << 'EOF'
#!/bin/sh
printf "command > "
read -r CMD
printf "%s\n" "$CMD" > "$TMPFILE"
EOF
  chmod +x "$NEW_SCRIPT"

  # ---------------------------------------------------------------------------
  # Jump picker
  # ---------------------------------------------------------------------------
  cat > "$JUMP_SCRIPT" << EOF
#!/bin/sh
RCACHE="${RCACHE}"
BCACHE="${BCACHE}"
SESSION="${SESSION}"
COMBINED=""

CMD=\$(tmux display-message -p -t "\${SESSION}:0.0" "#{pane_current_command}" 2>/dev/null | cut -c1-8)
COMBINED="\${COMBINED}pane:0 pane:0 * \${CMD}\n"
COMBINED="\${COMBINED}pane:6 pane:6 * calendar\n"

while IFS= read -r line; do
  [ -z "\$line" ] && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\$(( IDX + 1 )) \${REST}\n"
done < "\$RCACHE"

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
  # Kill picker
  # ---------------------------------------------------------------------------
  cat > "$KILL_SCRIPT" << EOF
#!/bin/sh
RCACHE="${RCACHE}"
BCACHE="${BCACHE}"
COMBINED=""

while IFS= read -r line; do
  [ -z "\$line" ] && continue
  echo "\$line" | grep -q " \* " && continue
  IDX=\$(echo "\$line" | awk '{print \$1}')
  REST=\$(echo "\$line" | cut -d' ' -f2-)
  COMBINED="\${COMBINED}right:\${IDX} right:\$(( IDX + 1 )) \${REST}\n"
done < "\$RCACHE"

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

  local DCONT_ID
  DCONT_ID=$(tmux display-message -p -t "$SESSION:0.6" "#{pane_id}")
  tmux set-environment -t "$SESSION" DEVOPEN_DCONT_ID "$DCONT_ID"
  local SWITCH="$SWITCH_SCRIPT"
  local NEW="$NEW_SCRIPT"
  local JUMP="$JUMP_SCRIPT"
  local KILL="$KILL_SCRIPT"

  # ---------------------------------------------------------------------------
  # Key bindings
  # ---------------------------------------------------------------------------

  # prefix+T — cycle to next tab
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

  # prefix+N — new tab with optional command
  tmux bind-key -T prefix N run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')
    case \"\$PANE\" in
      3|4) EC=DEVOPEN_RTAB_COUNT; ET=DEVOPEN_RTAB; EM=DEVOPEN_RMAP; CONTENT=\"${SESSION}:0.4\"; SHELF=\"${SESSION}:1\" ;;
      1|2) EC=DEVOPEN_BTAB_COUNT; ET=DEVOPEN_BTAB; EM=DEVOPEN_BMAP; CONTENT=\"${SESSION}:0.2\"; SHELF=\"${SESSION}:2\" ;;
      *) exit 0 ;;
    esac

    TMPFILE=\$(mktemp /tmp/devopen-cmd-XXXX)
    tmux popup -E -w 40 -h 3 \"TMPFILE=\$TMPFILE ${NEW}\"
    CMD=\$(cat \$TMPFILE); rm -f \$TMPFILE

    COUNT=\$(tmux show-environment -t \$SESSION \$EC | cut -d= -f2)
    CUR=\$(tmux show-environment   -t \$SESSION \$ET | cut -d= -f2)
    MAP=\$(tmux show-environment   -t \$SESSION \$EM | cut -d= -f2)
    DIR=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_path}')

    tmux split-window -h -t \"\$SHELF\" -c \"\$DIR\"
    NEW_SLOT=\$(( COUNT - 1 ))
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${NEW_SLOT}\"

    NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk \
      -v cur=\"\$CUR\" -v slot=\"\$NEW_SLOT\" \
      'NR==cur+1{print slot; next}{print}' \
      | tr '\n' ':' | sed 's/:\$//')
    NEW_MAP=\"\${NEW_MAP}:-\"

    NEWCOUNT=\$(( COUNT + 1 ))
    tmux set-environment -t \$SESSION \$EC \$NEWCOUNT
    tmux set-environment -t \$SESSION \$ET \$COUNT
    tmux set-environment -t \$SESSION \$EM \"\$NEW_MAP\"
    tmux select-pane -t \"\$CONTENT\"
    [ -n \"\$CMD\" ] && tmux send-keys -t \"\$CONTENT\" \"\$CMD\" C-m
    tmux display-message \"[\$NEWCOUNT/\$NEWCOUNT] new tab\"
  "

  # prefix+X — kill current tab
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

    PREV=\$(( (CUR - 1 + COUNT) % COUNT ))
    PREV_SLOT=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( PREV + 1 ))p\")
    tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${PREV_SLOT}\"
    tmux kill-pane -t \"\${SHELF}.\${PREV_SLOT}\"

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

  # ---------------------------------------------------------------------------
  # prefix+C — collapse/uncollapse (context-aware)
  #
  # Tag panes (1=bbar, 3=rbar, 5=dbar) redirect to their content pair.
  # Collapsed panes are resized to 1 (tmux minimum) not 0.
  # Tag panes never change size — only content panes and nvim resize.
  # ---------------------------------------------------------------------------
  tmux bind-key -T prefix C run-shell "
    SESSION=\$(tmux display-message -p '#S')
    PANE=\$(tmux display-message -p '#{pane_index}')

    case \"\$PANE\" in
      0)   TARGET=0 ;;
      1|2) TARGET=2 ;;
      3|4) TARGET=4 ;;
      5|6) TARGET=6 ;;
      *)   exit 0   ;;
    esac

    CVAR=\"DEVOPEN_COLLAPSED_\${TARGET}\"
    SVAR=\"DEVOPEN_SIZE_\${TARGET}\"
    COLLAPSED=\$(tmux show-environment -t \$SESSION \$CVAR 2>/dev/null | cut -d= -f2)
    SAVED=\$(tmux show-environment     -t \$SESSION \$SVAR 2>/dev/null | cut -d= -f2)

    if [ \"\$COLLAPSED\" = \"1\" ]; then
      # Uncollapse — restore saved size
      case \"\$TARGET\" in
        0)
          [ -z \"\$SAVED\" ] && SAVED=80
          tmux resize-pane -t '${SESSION}:0.0' -x \"\$SAVED\"
          ;;
        2)
          [ -z \"\$SAVED\" ] && SAVED=10
          tmux resize-pane -t '${SESSION}:0.2' -y \"\$SAVED\"
          tmux resize-pane -t '${SESSION}:0.1' -y 2
          ;;
        4)
          [ -z \"\$SAVED\" ] && SAVED=20
          tmux resize-pane -t '${SESSION}:0.4' -y \"\$SAVED\"
          tmux resize-pane -t '${SESSION}:0.3' -y 2
          COLL6=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_6 2>/dev/null | cut -d= -f2)
          [ \"\$COLL6\" = \"1\" ] && tmux resize-pane -t '${SESSION}:0.4' -y 9999
          ;;
        6)
          [ -z \"\$SAVED\" ] && SAVED=10
          tmux resize-pane -t '${SESSION}:0.6' -y \"\$SAVED\"
          tmux resize-pane -t '${SESSION}:0.5' -y 2
          ;;
      esac
      tmux set-environment -t \$SESSION \$CVAR 0

    else
      # Collapse — save current size, then resize to 1 (tmux minimum, not 0)
      case \"\$TARGET\" in
        0)
          CUR=\$(tmux display-message -p -t '${SESSION}:0.0' '#{pane_width}')
          tmux set-environment -t \$SESSION \$SVAR \"\$CUR\"
          tmux resize-pane -t '${SESSION}:0.0' -x 1
          ;;
        2)
          CUR=\$(tmux display-message -p -t '${SESSION}:0.2' '#{pane_height}')
          tmux set-environment -t \$SESSION \$SVAR \"\$CUR\"
          tmux resize-pane -t '${SESSION}:0.2' -y 1
          tmux resize-pane -t '${SESSION}:0.1' -y 2
          tmux resize-pane -t '${SESSION}:0.0' -y 9999
          ;;
        4)
          CUR=\$(tmux display-message -p -t '${SESSION}:0.4' '#{pane_height}')
          tmux set-environment -t \$SESSION \$SVAR \"\$CUR\"
          tmux resize-pane -t '${SESSION}:0.4' -y 1
          tmux resize-pane -t '${SESSION}:0.3' -y 2
          COLL6=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_6 2>/dev/null | cut -d= -f2)
          [ \"\$COLL6\" != \"1\" ] && tmux resize-pane -t '${SESSION}:0.6' -y 9999
          ;;
        6)
          CUR=\$(tmux display-message -p -t '${SESSION}:0.6' '#{pane_height}')
          tmux set-environment -t \$SESSION \$SVAR \"\$CUR\"
          tmux resize-pane -t '${SESSION}:0.6' -y 1
          tmux resize-pane -t '${SESSION}:0.5' -y 2
          tmux resize-pane -t '${SESSION}:0.4' -y 9999
          ;;
      esac
      tmux set-environment -t \$SESSION \$CVAR 1
    fi
  "

  # ---------------------------------------------------------------------------
  # prefix+G — fzf jump: select any tab or plain pane and focus it.
  # Uncollapses the target pane if it is collapsed before focusing.
  # ---------------------------------------------------------------------------
  tmux bind-key -T prefix G run-shell "
    SESSION=\$(tmux display-message -p '#S')
    TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
    tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${JUMP}\"
    SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
    [ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
    IDX=\$(echo \"\$IDX\" | tr -d '[:space:]')
    case \"\$SYS\" in
      pane)
        case \"\$IDX\" in
          0)
            COLLAPSED=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_0 2>/dev/null | cut -d= -f2)
            if [ \"\$COLLAPSED\" = \"1\" ]; then
              SAVED=\$(tmux show-environment -t \$SESSION DEVOPEN_SIZE_0 2>/dev/null | cut -d= -f2)
              [ -z \"\$SAVED\" ] && SAVED=80
              tmux resize-pane -t '${SESSION}:0.0' -x \"\$SAVED\"
              tmux set-environment -t \$SESSION DEVOPEN_COLLAPSED_0 0
            fi ;;
          2)
            COLLAPSED=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_2 2>/dev/null | cut -d= -f2)
            if [ \"\$COLLAPSED\" = \"1\" ]; then
              SAVED=\$(tmux show-environment -t \$SESSION DEVOPEN_SIZE_2 2>/dev/null | cut -d= -f2)
              [ -z \"\$SAVED\" ] && SAVED=10
              tmux resize-pane -t '${SESSION}:0.2' -y \"\$SAVED\"
              tmux resize-pane -t '${SESSION}:0.1' -y 2
              tmux set-environment -t \$SESSION DEVOPEN_COLLAPSED_2 0
            fi ;;
          4)
            COLLAPSED=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_4 2>/dev/null | cut -d= -f2)
            if [ \"\$COLLAPSED\" = \"1\" ]; then
              SAVED=\$(tmux show-environment -t \$SESSION DEVOPEN_SIZE_4 2>/dev/null | cut -d= -f2)
              [ -z \"\$SAVED\" ] && SAVED=20
              tmux resize-pane -t '${SESSION}:0.4' -y \"\$SAVED\"
              tmux resize-pane -t '${SESSION}:0.3' -y 2
              COLL6=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_6 2>/dev/null | cut -d= -f2)
              [ \"\$COLL6\" = \"1\" ] && tmux resize-pane -t '${SESSION}:0.4' -y 9999
              tmux set-environment -t \$SESSION DEVOPEN_COLLAPSED_4 0
            fi ;;
          6)
            COLLAPSED=\$(tmux show-environment -t \$SESSION DEVOPEN_COLLAPSED_6 2>/dev/null | cut -d= -f2)
            if [ \"\$COLLAPSED\" = \"1\" ]; then
              SAVED=\$(tmux show-environment -t \$SESSION DEVOPEN_SIZE_6 2>/dev/null | cut -d= -f2)
              [ -z \"\$SAVED\" ] && SAVED=10
              tmux resize-pane -t '${SESSION}:0.6' -y \"\$SAVED\"
              tmux resize-pane -t '${SESSION}:0.5' -y 2
              tmux set-environment -t \$SESSION DEVOPEN_COLLAPSED_6 0
            fi ;;
        esac
        tmux select-pane -t \"${SESSION}:0.\${IDX}\" ;;
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

  # Alt+1..9 — jump to tab by number (context-aware; pass-through on other panes)
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

  # h / ← / l / → — prev/next tab (only active on tab-bar panes 1 and 3)
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
  # Final setup — return to main window, focus nvim, resize panes.
  # dcont (pane 6) starts collapsed at 1 row — pane 4 claims freed space.
  # All bar panes pinned to 2 rows.
  # ---------------------------------------------------------------------------
  tmux select-window -t "$SESSION:0"
  tmux select-pane   -t "$SESSION:0.0"
  ( sleep 0.2
    tmux resize-pane -t "$SESSION:0.3" -y 2
    tmux resize-pane -t "$SESSION:0.1" -y 2
    tmux resize-pane -t "$SESSION:0.6" -y 1
    tmux resize-pane -t "$SESSION:0.5" -y 2
    tmux resize-pane -t "$SESSION:0.4" -y 9999
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

  rm -f /tmp/devopen-${SESSION}-*.sh \
        /tmp/devopen-${SESSION}-*.cache \
        /tmp/devopen-cmd-* \
        /tmp/devopen-sel-*

  tmux unbind-key -n h     2>/dev/null
  tmux unbind-key -n l     2>/dev/null
  tmux unbind-key -n Left  2>/dev/null
  tmux unbind-key -n Right 2>/dev/null
  local i
  for i in 1 2 3 4 5 6 7 8 9; do
    tmux unbind-key -n "M-$i" 2>/dev/null
  done

  tmux unbind-key -T prefix T 2>/dev/null
  tmux unbind-key -T prefix N 2>/dev/null
  tmux unbind-key -T prefix X 2>/dev/null
  tmux unbind-key -T prefix G 2>/dev/null
  tmux unbind-key -T prefix D 2>/dev/null
  tmux unbind-key -T prefix C 2>/dev/null

  tmux kill-session -t "$SESSION"
}
