#!/usr/bin/env bash
# Toggle the mouse and trackpad by commenting/uncommenting the marked 'off' nodes
# in the touchpad and mouse blocks of inputs.kdl, then regenerate cursor.kdl so
# the cursor is hidden while the pointer is disabled. niri hot-reloads the config.
# Used by both the DMS pill and the niri keybind (Mod+Shift+M).
set -euo pipefail

NIRI="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
INPUTS="$NIRI/inputs.kdl"

if grep -qE "^[[:space:]]*off[[:space:]]+// dms-pointer-toggle" "$INPUTS"; then
    # Pointer OFF -> enable it (comment the 'off' nodes)
    sed -i -E "s|^([[:space:]]*)off([[:space:]]+// dms-pointer-toggle)|\1// off\2|" "$INPUTS"
    state=enabled
else
    # Pointer ON -> disable it (uncomment the 'off' nodes)
    sed -i -E "s|^([[:space:]]*)// off([[:space:]]+// dms-pointer-toggle)|\1off\2|" "$INPUTS"
    state=disabled
fi

# Regenerate cursor.kdl to match the new pointer state (hide/show the cursor).
"$NIRI/scripts/sync-cursor.sh"

echo "$state"
