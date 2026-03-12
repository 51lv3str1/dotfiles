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

# ─── TMUX ────────────────────────────────────────────────────

# ─── Private helpers ─────────────────────────────────────────

function _devopen_script() {
  # Write a script to /tmp and make it executable.
  # Usage: _devopen_script <path> <content>
  printf '%s' "$2" > "$1"
  chmod +x "$1"
}

function _devopen_tmuxenv_get() {
  # Read a tmux session environment variable.
  # Usage: _devopen_tmuxenv_get <session> <var>
  tmux show-environment -t "$1" "$2" 2>/dev/null | cut -d= -f2
}

function _devopen_tmuxenv_set() {
  # Write a tmux session environment variable.
  # Usage: _devopen_tmuxenv_set <session> <var> <value>
  tmux set-environment -t "$1" "$2" "$3"
}

function _devopen_write_renderer() {
  # Write the shared tab-bar renderer script and launch it in both bar panes.
  # Usage: _devopen_write_renderer <session> <script_path> <rtabcache> <btabcache>
  local SESSION="$1"
  local SCRIPT="$2"
  local RTABCACHE="$3"
  local BTABCACHE="$4"

  _devopen_script "$SCRIPT" '#!/bin/zsh
SESSION="$1"
ENV_COUNT="$2"
ENV_CUR="$3"
ENV_MAP="$4"
CONTENT_PANE="$5"
SHELF_WIN="$6"
TABCACHE="$7"
RESET="\033[0m"
A_TEXT="\033[38;5;141m"
I_TEXT="\033[38;5;248m"
SEP="  "
while tmux has-session -t "$SESSION" 2>/dev/null; do
  COUNT=$(tmux show-environment -t "$SESSION" "$ENV_COUNT" 2>/dev/null | cut -d= -f2)
  CUR=$(tmux show-environment -t "$SESSION" "$ENV_CUR" 2>/dev/null | cut -d= -f2)
  MAP=$(tmux show-environment -t "$SESSION" "$ENV_MAP" 2>/dev/null | cut -d= -f2)
  [ -z "$COUNT" ] && sleep 0.1 && continue
  LINE=""
  CACHE=""
  i=0
  while (( i < COUNT )); do
    NUM=$(( i + 1 ))
    if [ "$i" = "$CUR" ]; then
      CMD=$(tmux display-message -p -t "${CONTENT_PANE}" "#{pane_current_command}" 2>/dev/null)
      CMD=$(echo "$CMD" | cut -c1-8)
      LINE="${LINE}${A_TEXT}● ${NUM}:${CMD}${RESET}${SEP}"
      CACHE="${CACHE}${i} * ${CMD}\n"
    else
      SHELF_IDX=$(echo "$MAP" | tr ":" "\n" | sed -n "$(( i + 1 ))p")
      CMD=$(tmux display-message -p -t "${SHELF_WIN}.${SHELF_IDX}" "#{pane_current_command}" 2>/dev/null)
      CMD=$(echo "$CMD" | cut -c1-8)
      LINE="${LINE}${I_TEXT}○ ${NUM}:${CMD}${RESET}${SEP}"
      CACHE="${CACHE}${i}   ${CMD}\n"
    fi
    (( i++ ))
  done
  printf "\033[H\033[2J"
  printf " ${LINE}\n"
  printf "${CACHE}" > "${TABCACHE}"
  sleep 0.1
done
'

  # Launch right renderer (pane 3)
  tmux send-keys -t "$SESSION":0.3 \
    "$SCRIPT $SESSION DEVOPEN_RTAB_COUNT DEVOPEN_RTAB DEVOPEN_RMAP ${SESSION}:0.4 ${SESSION}:1 $RTABCACHE" Enter

  # Launch bottom renderer (pane 1)
  tmux send-keys -t "$SESSION":0.1 \
    "$SCRIPT $SESSION DEVOPEN_BTAB_COUNT DEVOPEN_BTAB DEVOPEN_BMAP ${SESSION}:0.2 ${SESSION}:2 $BTABCACHE" Enter
}

function _devopen_write_switch() {
  # Write the shared pane-swap script.
  # Usage: _devopen_write_switch <session> <script_path>
  local SESSION="$1"
  local SCRIPT="$2"

  _devopen_script "$SCRIPT" "#!/bin/zsh
SESSION=\"${SESSION}\"
SYSTEM=\"\$1\"
IDX=\"\$2\"
if [ \"\$SYSTEM\" = \"right\" ]; then
  ENV_TAB=\"DEVOPEN_RTAB\"
  ENV_COUNT=\"DEVOPEN_RTAB_COUNT\"
  ENV_MAP=\"DEVOPEN_RMAP\"
  CONTENT_PANE=\"\${SESSION}:0.4\"
  SHELF_WIN=\"\${SESSION}:1\"
else
  ENV_TAB=\"DEVOPEN_BTAB\"
  ENV_COUNT=\"DEVOPEN_BTAB_COUNT\"
  ENV_MAP=\"DEVOPEN_BMAP\"
  CONTENT_PANE=\"\${SESSION}:0.2\"
  SHELF_WIN=\"\${SESSION}:2\"
fi
COUNT=\$(tmux show-environment -t \"\$SESSION\" \"\$ENV_COUNT\" | cut -d= -f2)
CUR=\$(tmux show-environment -t \"\$SESSION\" \"\$ENV_TAB\" | cut -d= -f2)
[ -z \"\$IDX\" ] && exit 0
[ \"\$IDX\" -ge \"\$COUNT\" ] && tmux display-message -t \"\$SESSION\" \"No tab \$(( IDX + 1 ))\" && exit 0
[ \"\$IDX\" = \"\$CUR\" ] && exit 0
MAP=\$(tmux show-environment -t \"\$SESSION\" \"\$ENV_MAP\" 2>/dev/null | cut -d= -f2)
TARGET_SHELF=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( IDX + 1 ))p\")
tmux swap-pane -s \"\$CONTENT_PANE\" -t \"\${SHELF_WIN}.\${TARGET_SHELF}\"
NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk -v cur=\"\$CUR\" -v idx=\"\$IDX\" -v slot=\"\$TARGET_SHELF\" '
  NR == cur+1 { print slot; next }
  NR == idx+1 { print \"-\"; next }
  { print }
' | tr '\n' ':' | sed 's/:\$//')
tmux set-environment -t \"\$SESSION\" \"\$ENV_MAP\" \"\$NEW_MAP\"
tmux set-environment -t \"\$SESSION\" \"\$ENV_TAB\" \"\$IDX\"
tmux select-pane -t \"\$CONTENT_PANE\"
CMD=\$(tmux display-message -p -t \"\$CONTENT_PANE\" '#{pane_current_command}')
tmux display-message -t \"\$SESSION\" \"[\$(( IDX + 1 ))/\$COUNT] \$CMD\"
"
}

function _devopen_write_new() {
  # Write the popup command-prompt script.
  # Usage: _devopen_write_new <script_path>
  _devopen_script "$1" '#!/bin/zsh
printf "command > "
read -r CMD
printf "%s\n" "$CMD" > "$TMPFILE"
'
}

function _devopen_write_tabpick() {
  # Write the shared fzf picker script (jump + kill modes).
  # Usage: _devopen_write_tabpick <session> <script_path> <rtabcache> <btabcache>
  local SESSION="$1"
  local SCRIPT="$2"
  local RTABCACHE="$3"
  local BTABCACHE="$4"

  _devopen_script "$SCRIPT" "#!/bin/zsh
MODE=\"\$1\"   # jump | kill
RTABCACHE=\"${RTABCACHE}\"
BTABCACHE=\"${BTABCACHE}\"
SESSION=\"${SESSION}\"
COMBINED=\"\"
if [ \"\$MODE\" = \"jump\" ]; then
  CMD=\$(tmux display-message -p -t \"\${SESSION}:0.0\" '#{pane_current_command}' 2>/dev/null | cut -c1-8)
  COMBINED=\"\${COMBINED}pane:0 pane:0 * \${CMD}\n\"
fi
for cache_sys in \"\${RTABCACHE}:right\" \"\${BTABCACHE}:bottom\"; do
  CACHE=\${cache_sys%%:*}
  SYS=\${cache_sys##*:}
  while IFS= read -r line; do
    [ -z \"\$line\" ] && continue
    [ \"\$MODE\" = \"kill\" ] && echo \"\$line\" | grep -q \" \* \" && continue
    IDX=\$(echo \"\$line\" | awk '{print \$1}')
    NUM=\$(( IDX + 1 ))
    REST=\$(echo \"\$line\" | cut -d' ' -f2-)
    COMBINED=\"\${COMBINED}\${SYS}:\${IDX} \${SYS}:\${NUM} \${REST}\n\"
  done < \"\$CACHE\"
done
[ -z \"\$COMBINED\" ] && printf \"\n\" > \"\$TMPFILE\" && exit 0
if [ \"\$MODE\" = \"jump\" ]; then
  PROMPT=\"jump > \"
  COLOR=\"prompt:#89b4fa,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#a6e3a1\"
else
  PROMPT=\"kill > \"
  COLOR=\"prompt:#f38ba8,pointer:#f38ba8,bg:#1e1e2e,bg+:#313244,fg+:#f38ba8\"
fi
SELECTED=\$(printf \"%b\" \"\$COMBINED\" | fzf \\
  --prompt=\"\$PROMPT\" \\
  --height=100% \\
  --layout=reverse \\
  --border=none \\
  --with-nth=2.. \\
  --color=\"\$COLOR\" \\
  --preview-window=hidden)
[ -z \"\$SELECTED\" ] && printf \"\n\" > \"\$TMPFILE\" && exit 0
SYS=\$(echo \"\$SELECTED\" | awk '{print \$1}' | cut -d: -f1)
IDX=\$(echo \"\$SELECTED\" | awk '{print \$1}' | cut -d: -f2)
printf \"%s\n%s\n\" \"\$SYS\" \"\$IDX\" > \"\$TMPFILE\"
"
}

function _devopen_write_tabnew() {
  # Write the new-tab script.
  # Usage: _devopen_write_tabnew <session> <script_path> <new_script>
  local SESSION="$1"
  local SCRIPT="$2"
  local NEW_SCRIPT="$3"

  _devopen_script "$SCRIPT" "#!/bin/zsh
SESSION=\$(tmux display-message -p '#S')
PANE=\$(tmux display-message -p '#{pane_index}')
case \"\$PANE\" in
  3|4) EC=DEVOPEN_RTAB_COUNT; ET=DEVOPEN_RTAB; EM=DEVOPEN_RMAP; CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\" ;;
  1|2) EC=DEVOPEN_BTAB_COUNT; ET=DEVOPEN_BTAB; EM=DEVOPEN_BMAP; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\" ;;
  *) exit 0 ;;
esac
TMPFILE=\$(mktemp /tmp/devopen-cmd-XXXX)
tmux popup -E -w 40 -h 3 \"TMPFILE=\$TMPFILE ${NEW_SCRIPT}\"
CMD=\$(cat \$TMPFILE); rm -f \$TMPFILE
COUNT=\$(tmux show-environment -t \"\$SESSION\" \"\$EC\" | cut -d= -f2)
MAP=\$(tmux show-environment -t \"\$SESSION\" \"\$EM\" | cut -d= -f2)
DIR=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_path}')
tmux split-window -t \"\$SHELF\" -h -c \"\$DIR\"
NEW_SHELF_SLOT=\$(( COUNT - 1 ))
tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${NEW_SHELF_SLOT}\"
NEWCOUNT=\$(( COUNT + 1 ))
tmux set-environment -t \"\$SESSION\" \"\$EC\" \$NEWCOUNT
tmux set-environment -t \"\$SESSION\" \"\$ET\" \$COUNT
CUR_IDX=\$(tmux show-environment -t \"\$SESSION\" \"\$ET\" | cut -d= -f2)
NEW_MAP=\$(echo \"\${MAP}:\${NEW_SHELF_SLOT}\" | tr ':' '\n' | awk -v cur=\"\$CUR_IDX\" -v slot=\"\$NEW_SHELF_SLOT\" 'NR==cur+1{print slot; next}{print}' | tr '\n' ':' | sed 's/:\$//')
NEW_MAP=\"\${NEW_MAP}:-\"
tmux set-environment -t \"\$SESSION\" \"\$EM\" \"\$NEW_MAP\"
tmux select-pane -t \"\$CONTENT\"
[ -n \"\$CMD\" ] && tmux send-keys -t \"\$CONTENT\" \"\$CMD\" Enter
tmux display-message \"[\$NEWCOUNT/\$NEWCOUNT] zsh\"
"
}

function _devopen_write_tabkillcur() {
  # Write the kill-active-tab script.
  # Usage: _devopen_write_tabkillcur <session> <script_path>
  local SESSION="$1"
  local SCRIPT="$2"

  _devopen_script "$SCRIPT" "#!/bin/zsh
SESSION=\$(tmux display-message -p '#S')
PANE=\$(tmux display-message -p '#{pane_index}')
case \"\$PANE\" in
  3|4) ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\" ;;
  1|2) ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\" ;;
  *) exit 0 ;;
esac
COUNT=\$(tmux show-environment -t \"\$SESSION\" \"\$EC\" | cut -d= -f2)
CUR=\$(tmux show-environment -t \"\$SESSION\" \"\$ET\" | cut -d= -f2)
[ \"\$COUNT\" -le 1 ] && tmux display-message 'Cannot close last tab' && exit 0
MAP=\$(tmux show-environment -t \"\$SESSION\" \"\$EM\" | cut -d= -f2)
PREV=\$(( (CUR - 1 + COUNT) % COUNT ))
PREV_SHELF=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( PREV + 1 ))p\")
tmux swap-pane -s \"\$CONTENT\" -t \"\${SHELF}.\${PREV_SHELF}\"
tmux kill-pane -t \"\${SHELF}.\${PREV_SHELF}\"
NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk -v cur=\"\$CUR\" -v prev=\"\$PREV\" -v slot=\"\$PREV_SHELF\" '
  NR == prev+1 { next }
  NR == cur+1  { print \"-\"; next }
  { val=\$0+0; if (val > slot) val--; print val }
' | tr '\n' ':' | sed 's/:\$//')
NEWCOUNT=\$(( COUNT - 1 ))
tmux set-environment -t \"\$SESSION\" \"\$EC\" \$NEWCOUNT
tmux set-environment -t \"\$SESSION\" \"\$ET\" \$PREV
tmux set-environment -t \"\$SESSION\" \"\$EM\" \"\$NEW_MAP\"
tmux select-pane -t \"\$CONTENT\"
CMD=\$(tmux display-message -p -t \"\$CONTENT\" '#{pane_current_command}')
tmux display-message \"[\$(( PREV + 1 ))/\$NEWCOUNT] \$CMD\"
"
}

function _devopen_write_tabjump() {
  # Write the fzf jump script.
  # Usage: _devopen_write_tabjump <session> <script_path> <switch_script> <tabpick_script>
  local SESSION="$1"
  local SCRIPT="$2"
  local SWITCH_SCRIPT="$3"
  local TABPICK_SCRIPT="$4"

  _devopen_script "$SCRIPT" "#!/bin/zsh
SESSION=\$(tmux display-message -p '#S')
TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${TABPICK_SCRIPT} jump\"
SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
[ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
if [ \"\$SYS\" = \"pane\" ]; then
  tmux select-pane -t \"\${SESSION}:0.\${IDX}\"
elif [ \"\$SYS\" = \"right\" ]; then
  ${SWITCH_SCRIPT} right \"\$IDX\"
  tmux select-pane -t \"\${SESSION}:0.4\"
else
  ${SWITCH_SCRIPT} bottom \"\$IDX\"
  tmux select-pane -t \"\${SESSION}:0.2\"
fi
"
}

function _devopen_write_tabkillfzf() {
  # Write the fzf kill script.
  # Usage: _devopen_write_tabkillfzf <session> <script_path> <switch_script> <tabpick_script>
  local SESSION="$1"
  local SCRIPT="$2"
  local SWITCH_SCRIPT="$3"
  local TABPICK_SCRIPT="$4"

  _devopen_script "$SCRIPT" "#!/bin/zsh
SESSION=\$(tmux display-message -p '#S')
RCOUNT=\$(tmux show-environment -t \"\$SESSION\" DEVOPEN_RTAB_COUNT | cut -d= -f2)
BCOUNT=\$(tmux show-environment -t \"\$SESSION\" DEVOPEN_BTAB_COUNT | cut -d= -f2)
[ \$(( RCOUNT + BCOUNT )) -le 2 ] && tmux display-message 'Cannot close last tab in each pane' && exit 0
TMPFILE=\$(mktemp /tmp/devopen-sel-XXXX)
tmux popup -E -w 50 -h 20 \"TMPFILE=\$TMPFILE ${TABPICK_SCRIPT} kill\"
SYS=\$(sed -n '1p' \$TMPFILE); IDX=\$(sed -n '2p' \$TMPFILE); rm -f \$TMPFILE
[ -z \"\$SYS\" ] || [ -z \"\$IDX\" ] && exit 0
if [ \"\$SYS\" = \"right\" ]; then
  ET=DEVOPEN_RTAB; EC=DEVOPEN_RTAB_COUNT; EM=DEVOPEN_RMAP; CONTENT=\"\${SESSION}:0.4\"; SHELF=\"\${SESSION}:1\"
else
  ET=DEVOPEN_BTAB; EC=DEVOPEN_BTAB_COUNT; EM=DEVOPEN_BMAP; CONTENT=\"\${SESSION}:0.2\"; SHELF=\"\${SESSION}:2\"
fi
COUNT=\$(tmux show-environment -t \"\$SESSION\" \"\$EC\" | cut -d= -f2)
[ \"\$COUNT\" -le 1 ] && tmux display-message 'Cannot close last tab in this pane' && exit 0
CUR=\$(tmux show-environment -t \"\$SESSION\" \"\$ET\" | cut -d= -f2)
MAP=\$(tmux show-environment -t \"\$SESSION\" \"\$EM\" | cut -d= -f2)
SHELF_IDX=\$(echo \"\$MAP\" | tr ':' '\n' | sed -n \"\$(( IDX + 1 ))p\")
tmux kill-pane -t \"\${SHELF}.\${SHELF_IDX}\"
NEW_MAP=\$(echo \"\$MAP\" | tr ':' '\n' | awk -v idx=\"\$IDX\" -v slot=\"\$SHELF_IDX\" '
  NR == idx+1 { next }
  { val=\$0; if (val != \"-\" && val+0 > slot) val=val-1; print val }
' | tr '\n' ':' | sed 's/:\$//')
NEWCOUNT=\$(( COUNT - 1 ))
tmux set-environment -t \"\$SESSION\" \"\$EC\" \$NEWCOUNT
NEWCUR=\$CUR
[ \"\$IDX\" -lt \"\$CUR\" ] && NEWCUR=\$(( CUR - 1 ))
tmux set-environment -t \"\$SESSION\" \"\$ET\" \$NEWCUR
tmux set-environment -t \"\$SESSION\" \"\$EM\" \"\$NEW_MAP\"
tmux display-message \"Killed \$SYS tab \$(( IDX + 1 )) [\$NEWCOUNT left]\"
"
}

function _devopen_write_tabnav() {
  # Write the h/l/←/→ nav script and bind the keys.
  # Usage: _devopen_write_tabnav <session> <script_path> <switch_script>
  local SESSION="$1"
  local SCRIPT="$2"
  local SWITCH_SCRIPT="$3"

  _devopen_script "$SCRIPT" "#!/bin/zsh
DIR=\"\$1\"   # next | prev
FALLBACK=\"\$2\"
SESSION=\$(tmux display-message -p '#S')
PANE=\$(tmux display-message -p '#{pane_index}')
case \"\$PANE\" in
  3|4) SYS=right;  EC=DEVOPEN_RTAB_COUNT; ET=DEVOPEN_RTAB ;;
  1|2) SYS=bottom; EC=DEVOPEN_BTAB_COUNT; ET=DEVOPEN_BTAB ;;
  *)   tmux send-keys \"\$FALLBACK\"; exit 0 ;;
esac
COUNT=\$(tmux show-environment -t \"\$SESSION\" \"\$EC\" | cut -d= -f2)
CUR=\$(tmux show-environment -t \"\$SESSION\" \"\$ET\" | cut -d= -f2)
if [ \"\$DIR\" = \"next\" ]; then
  NEXT=\$(( (CUR + 1) % COUNT ))
else
  NEXT=\$(( (CUR - 1 + COUNT) % COUNT ))
fi
${SWITCH_SCRIPT} \"\$SYS\" \"\$NEXT\"
"

}

function _devopen_bind_keys() {
  # Register all tmux prefix keybindings.
  # Usage: _devopen_bind_keys <switch> <tabnew> <tabkillcur> <tabjump> <tabkillfzf>
  local SWITCH="$1"
  local TABNEW="$2"
  local TABKILLCUR="$3"
  local TABJUMP="$4"
  local TABKILLFZF="$5"

  # prefix+T: cycle next tab
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
    ${SWITCH} \$SYS \$(( (CUR + 1) % COUNT ))
  "

  tmux bind-key -T prefix N run-shell "$TABNEW"
  tmux bind-key -T prefix X run-shell "$TABKILLCUR"
  tmux bind-key -T prefix G run-shell "$TABJUMP"
  tmux bind-key -T prefix D run-shell "$TABKILLFZF"

  # Alt+1-9: jump by number
  local IDX
  for i in {1..9}; do
    IDX=$(( i - 1 ))
    tmux bind-key -n "M-$i" run-shell "
      PANE=\$(tmux display-message -p '#{pane_index}')
      case \"\$PANE\" in
        3|4) ${SWITCH} right ${IDX} ;;
        1|2) ${SWITCH} bottom ${IDX} ;;
        *)   tmux send-keys 'M-$i' ;;
      esac
    "
  done
}

function _devopen_cleanup_scripts() {
  # Remove all session-scoped temp scripts and caches.
  # Usage: _devopen_cleanup_scripts <session>
  local SESSION="$1"
  rm -f \
    "/tmp/devopen-tabrender-${SESSION}.sh"  \
    "/tmp/devopen-switch-${SESSION}.sh"     \
    "/tmp/devopen-new-${SESSION}.sh"        \
    "/tmp/devopen-tabpick-${SESSION}.sh"    \
    "/tmp/devopen-tabnew-${SESSION}.sh"     \
    "/tmp/devopen-tabkillcur-${SESSION}.sh" \
    "/tmp/devopen-tabjump-${SESSION}.sh"    \
    "/tmp/devopen-tabkillfzf-${SESSION}.sh" \
    "/tmp/devopen-rtabs-${SESSION}.cache"   \
    "/tmp/devopen-btabs-${SESSION}.cache"
  rm -f /tmp/devopen-cmd-* /tmp/devopen-sel-*
}

function _devopen_unbind_keys() {
  # Remove all keybindings set by devopen.
  for i in {1..9}; do
    tmux unbind-key -n "M-$i" 2>/dev/null
  done
  tmux unbind-key -T prefix T 2>/dev/null
  tmux unbind-key -T prefix N 2>/dev/null
  tmux unbind-key -T prefix X 2>/dev/null
  tmux unbind-key -T prefix G 2>/dev/null
  tmux unbind-key -T prefix D 2>/dev/null
}

# ─── Public API ──────────────────────────────────────────────

function devopen() {
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

  # ── Layout ──────────────────────────────────────────────────
  # ┌─────────────────────┬──────────┐
  # │                     │ [rbar] 3 │  right tab-bar
  # │       nvim          ├──────────┤
  # │       pane 0        │ rcontent │  pane 4
  # │                     │          │
  # ├─────────────────────┤          │
  # │ [bbar]    pane 1    │          │  bottom tab-bar
  # ├─────────────────────┤          │
  # │ bcontent  pane 2    │          │  bottom tab-content
  # └─────────────────────┴──────────┘
  tmux new-session -d -s "$SESSION" -c "$DIR" -x "$(tput cols)" -y "$(tput lines)"
  tmux split-window -h -p 25 -t "$SESSION":0.0 -c "$DIR"
  tmux select-pane  -t "$SESSION":0.0
  tmux split-window -v -p 30 -t "$SESSION":0.0 -c "$DIR"
  tmux select-pane  -t "$SESSION":0.1
  tmux split-window -v -p 90 -t "$SESSION":0.1 -c "$DIR"
  tmux select-pane  -t "$SESSION":0.3
  tmux split-window -v -p 90 -t "$SESSION":0.3 -c "$DIR"

  # ── Initial pane commands ───────────────────────────────────
  tmux send-keys -t "$SESSION":0.0 "nvim \"$FILE\"" Enter
  tmux send-keys -t "$SESSION":0.4 "clear && claude" Enter
  tmux send-keys -t "$SESSION":0.2 "clear && zsh" Enter

  # ── Right shelf (window 1): lazygit + lazydocker ────────────
  tmux new-window    -t "$SESSION" -c "$DIR" -n "tabs-right"
  tmux split-window  -h -t "$SESSION":1 -c "$DIR"
  tmux send-keys     -t "$SESSION":1.0 "clear && lazygit" Enter
  tmux send-keys     -t "$SESSION":1.1 "clear && lazydocker" Enter
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_RTAB       0
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_RTAB_COUNT 3
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_RMAP       "-:0:1"

  # ── Bottom shelf (window 2): zsh ────────────────────────────
  tmux new-window    -t "$SESSION" -c "$DIR" -n "tabs-bottom"
  tmux send-keys     -t "$SESSION":2.0 'clear' Enter
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_BTAB       0
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_BTAB_COUNT 1
  _devopen_tmuxenv_set "$SESSION" DEVOPEN_BMAP       "-"

  # ── Script paths ─────────────────────────────────────────────
  local RENDERER="/tmp/devopen-tabrender-${SESSION}.sh"
  local RTABCACHE="/tmp/devopen-rtabs-${SESSION}.cache"
  local BTABCACHE="/tmp/devopen-btabs-${SESSION}.cache"
  local SWITCH="/tmp/devopen-switch-${SESSION}.sh"
  local NEW="/tmp/devopen-new-${SESSION}.sh"
  local TABPICK="/tmp/devopen-tabpick-${SESSION}.sh"
  local TABNEW="/tmp/devopen-tabnew-${SESSION}.sh"
  local TABKILLCUR="/tmp/devopen-tabkillcur-${SESSION}.sh"
  local TABJUMP="/tmp/devopen-tabjump-${SESSION}.sh"
  local TABKILLFZF="/tmp/devopen-tabkillfzf-${SESSION}.sh"

  # ── Write scripts ────────────────────────────────────────────
  _devopen_write_renderer   "$SESSION" "$RENDERER"   "$RTABCACHE" "$BTABCACHE"
  _devopen_write_switch     "$SESSION" "$SWITCH"
  _devopen_write_new                   "$NEW"
  _devopen_write_tabpick    "$SESSION" "$TABPICK"    "$RTABCACHE" "$BTABCACHE"
  _devopen_write_tabnew     "$SESSION" "$TABNEW"     "$NEW"
  _devopen_write_tabkillcur "$SESSION" "$TABKILLCUR"
  _devopen_write_tabjump    "$SESSION" "$TABJUMP"    "$SWITCH"    "$TABPICK"
  _devopen_write_tabkillfzf "$SESSION" "$TABKILLFZF" "$SWITCH"    "$TABPICK"

  # ── Bind keys ────────────────────────────────────────────────
  _devopen_unbind_keys
  _devopen_bind_keys "$SWITCH" "$TABNEW" "$TABKILLCUR" "$TABJUMP" "$TABKILLFZF"

  # ── Focus and resize ─────────────────────────────────────────
  tmux select-window -t "$SESSION:0"
  tmux select-pane   -t "$SESSION":0.0
  (sleep 0.2 && \
    tmux resize-pane -t "$SESSION":0.3 -y 2 && \
    tmux resize-pane -t "$SESSION":0.1 -y 2) &
  tmux attach -t "$SESSION"
}

function devclose() {
  local SESSION
  SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  if [ -z "$SESSION" ]; then
    echo "devclose: not inside a tmux session"
    return 1
  fi
  echo "devclose: closing session '$SESSION' and cleaning up..."
  _devopen_cleanup_scripts "$SESSION"
  _devopen_unbind_keys
  tmux kill-session -t "$SESSION"
}
