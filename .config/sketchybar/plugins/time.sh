#!/bin/bash

HOUR=$(date '+%H:%M')
DATE=$(date '+%a %-d' | awk '{print tolower($0)}')
sketchybar --set "$NAME" label="$HOUR  ·  $DATE"
