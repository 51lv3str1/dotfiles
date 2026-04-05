#!/bin/bash

sketchybar --add item front_app left \
  --set front_app \
  background.color=$ACCENT_COLOR \
  padding_left=10 \
  icon.color=$ITEM_COLOR \
  label.color=$ITEM_COLOR \
  icon.font="DepartureMono Nerd Font:Regular:12.0" \
  label.font="DepartureMono Nerd Font:11.5" \
  script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched
