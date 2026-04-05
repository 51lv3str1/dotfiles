#!/bin/bash

RSSI=$(system_profiler SPAirPortDataType 2>/dev/null | grep "Signal / Noise" | head -1 | awk '{print $4}')
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰤭"
elif [ -z "$RSSI" ]; then
  sketchybar --set "$NAME" icon="󰤨"
elif [ "$RSSI" -ge -50 ]; then
  sketchybar --set "$NAME" icon="󰤨"
elif [ "$RSSI" -ge -60 ]; then
  sketchybar --set "$NAME" icon="󰤥"
elif [ "$RSSI" -ge -70 ]; then
  sketchybar --set "$NAME" icon="󰤢"
else
  sketchybar --set "$NAME" icon="󰤟"
fi
