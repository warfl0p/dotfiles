#!/usr/bin/env bash
set -euo pipefail

HIST_SRC="$HOME/.zsh_history"
DEST_DIR="$HOME/Seafile/Backups/zsh_history"
RETENTION_DAYS=90

mkdir -p "$DEST_DIR"

if [[ -f "$HIST_SRC" ]]; then
    cp "$HIST_SRC" "$DEST_DIR/zsh_history_$(date +%Y-%m-%d).bak"
fi

find "$DEST_DIR" -name 'zsh_history_*.bak' -mtime "+$RETENTION_DAYS" -delete
