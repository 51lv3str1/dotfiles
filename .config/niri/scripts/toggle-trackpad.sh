#!/usr/bin/env bash
# Toggle the mouse and trackpad, hiding/showing the cursor accordingly, by
# commenting/uncommenting the marked nodes in the niri config. niri hot-reloads
# the config. Used by both the DMS pill and the niri keybind (Mod+Shift+M).
set -euo pipefail

NIRI="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
INPUTS="$NIRI/inputs.kdl"
CURSOR="$NIRI/cursor.kdl"

if grep -qE "^[[:space:]]*off[[:space:]]+// dms-pointer-toggle" "$INPUTS"; then
    # Pointer is OFF -> enable input and show the cursor again
    sed -i -E "s|^([[:space:]]*)off([[:space:]]+// dms-pointer-toggle)|\1// off\2|" "$INPUTS"
    sed -i -E "s|^([[:space:]]*)hide-after-inactive-ms 1([[:space:]]+// dms-pointer-toggle)|\1// hide-after-inactive-ms 1\2|" "$CURSOR"
    echo enabled
else
    # Pointer is ON -> disable input and hide the (now frozen) cursor
    sed -i -E "s|^([[:space:]]*)// off([[:space:]]+// dms-pointer-toggle)|\1off\2|" "$INPUTS"
    sed -i -E "s|^([[:space:]]*)// hide-after-inactive-ms 1([[:space:]]+// dms-pointer-toggle)|\1hide-after-inactive-ms 1\2|" "$CURSOR"
    echo disabled
fi
