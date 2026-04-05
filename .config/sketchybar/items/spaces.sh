#!/bin/bash

for space in $(yabai -m query --spaces | python3 -c "import sys,json; [print(s['index']) for s in json.load(sys.stdin)]"); do
  sketchybar --add space space.$space left \
    --set space.$space \
    space=$space \
    icon="$space" \
    icon.font="DepartureMono Nerd Font:Regular:11.5" \
    padding_right=4 \
    padding_left=4 \
    icon.padding_left=5 \
    icon.padding_right=5 \
    icon.y_offset=1 \
    label.drawing=off \
    background.drawing=on \
    background.color=0xff3a3a4a \
    background.height=16 \
    background.corner_radius=8 \
    background.border_width=0 \
    icon.color=0xff888899 \
    script="$PLUGIN_DIR/spaces.sh" \
    click_script="yabai -m space --focus $space" \
    --subscribe space.$space space_change
done

sketchybar --add bracket spaces_island \
  space.1 space.2 space.3 space.4 space.5 \
  --set spaces_island \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  padding_left=2 \
  padding_right=2
