#!/usr/bin/env bash
# Toggle the trackpad by commenting/uncommenting the marked 'off' node in the
# touchpad block of inputs.kdl. niri hot-reloads the config automatically.
# Used by both the DMS pill and the niri keybind (Mod+Shift+M).
set -euo pipefail

CONF="${XDG_CONFIG_HOME:-$HOME/.config}/niri/inputs.kdl"

if grep -qE "^[[:space:]]*off[[:space:]]+// dms-trackpad-toggle" "$CONF"; then
    # Trackpad OFF -> enable it (comment the 'off' node)
    sed -i -E "s|^([[:space:]]*)off([[:space:]]+// dms-trackpad-toggle)|\1// off\2|" "$CONF"
    echo enabled
else
    # Trackpad ON -> disable it (uncomment the 'off' node)
    sed -i -E "s|^([[:space:]]*)// off([[:space:]]+// dms-trackpad-toggle)|\1off\2|" "$CONF"
    echo disabled
fi
