#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL=$(hyprctl monitors -j | jq -r --arg i "$INTERNAL" '[.[].name | select(. != $i)][0] // empty')

move() {
  hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$1\", monitor = \"$2\" })" >/dev/null
}

if [ -n "$EXTERNAL" ]; then
  echo "External monitor connected ($EXTERNAL)"
  for ws in {1..9}; do move "$ws" "$EXTERNAL"; done
  move 10 "$INTERNAL"
else
  echo "No external monitor connected"
  for ws in {1..10}; do move "$ws" "$INTERNAL"; done
fi
