#!/usr/bin/env bash

for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
  if [ "$monitor" != "eDP-1" ]; then
    hyprctl keyword monitor "$monitor,disable"
  fi
done

hyprctl keyword monitor "eDP-1,preferred,auto,1"
