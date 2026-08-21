#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNALS=("DP-1" "DP-7" "DP-2" "DP-8" "DP-9" "DP-10" "DP-11" "HDMI-A-1")

# Detect connected external monitor
CONNECTED_EXTERNAL=""
for MON in "${EXTERNALS[@]}"; do
  if hyprctl monitors | grep -qw "$MON"; then
    CONNECTED_EXTERNAL="$MON"
    break
  fi
done

if [ -n "$CONNECTED_EXTERNAL" ]; then
  echo "External monitor connected ($CONNECTED_EXTERNAL)"

  # Move workspaces 1–9 to external
  for ws in {1..9}; do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$CONNECTED_EXTERNAL"
  done

  # Keep workspace 10 on laptop
  hyprctl dispatch moveworkspacetomonitor 10 "$INTERNAL"

else
  echo "No external monitor connected"

  # Move everything back to laptop
  for ws in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$INTERNAL"
  done
fi
