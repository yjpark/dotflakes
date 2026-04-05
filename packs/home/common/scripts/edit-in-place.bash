#!/usr/bin/env bash

source `which color-logging`

set -euo pipefail

if [ -z "${1:-}" ]; then
    error "Usage: edit-in-place <filename>"
    exit 1
fi

FILE="$1"

if [ ! -e "$FILE" ]; then
    error "File not found: $FILE"
    exit 1
fi

BAK="${FILE}.bak"

# Save original as .bak first, then replace with writable copy
cp "$FILE" "$BAK"
rm -f "$FILE"
cp "$BAK" "$FILE"
chmod 644 "$FILE"

info "Backed up to $BAK and made $FILE writable"
