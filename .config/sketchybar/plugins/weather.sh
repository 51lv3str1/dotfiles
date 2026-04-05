#!/bin/bash

WEATHER=$(curl -sf "https://wttr.in/Buenos+Aires?format=%c%t" 2>/dev/null | tr -d '+' | sed 's/°C/°C/')

if [ -z "$WEATHER" ]; then
  sketchybar --set "$NAME" icon="" label="--°C"
else
  sketchybar --set "$NAME" icon="" label="$WEATHER"
fi
