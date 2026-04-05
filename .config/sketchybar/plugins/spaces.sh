#!/bin/sh

source "$CONFIG_DIR/colors.sh"

SPACES_JSON=$(yabai -m query --spaces)
FOCUSED=$(echo "$SPACES_JSON" | jq -r '.[] | select(."has-focus" == true) | .index')

UPDATE_CMD="sketchybar --animate cubic 34"

for space in $(echo "$SPACES_JSON" | jq -r '.[].index'); do
  if [ "$space" = "$FOCUSED" ]; then
    UPDATE_CMD="$UPDATE_CMD --set space.$space \
      background.color=0xffb4a0d4 \
      background.corner_radius=11 \
      icon.padding_left=11 \
      icon.padding_right=11 \
      icon.color=0xff1e1e2e"
  else
    UPDATE_CMD="$UPDATE_CMD --set space.$space \
      background.color=0xff3a3a4a \
      background.corner_radius=11 \
      icon.padding_left=5 \
      icon.padding_right=5 \
      icon.color=0xff888899"
  fi
done

eval "$UPDATE_CMD"
