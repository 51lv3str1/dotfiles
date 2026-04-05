#!/bin/bash

BT=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "State:" | head -1 | awk '{print $2}')

if [ "$BT" = "On" ]; then
  sketchybar --set "$NAME" icon="󰂯" icon.color=0xffcdd6f4
else
  sketchybar --set "$NAME" icon="󰂲" icon.color=0xff555570
fi
