#!/bin/bash

VOL=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ]; then
  ICON="󰝟"
elif [ "$VOL" -ge 66 ]; then
  ICON="󰕾"
elif [ "$VOL" -ge 33 ]; then
  ICON="󰖀"
else
  ICON="󰕿"
fi

sketchybar --set "$NAME" icon="$ICON"
