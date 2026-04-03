#!/usr/bin/env bash
set -euo pipefail

FROM="${TCP_PORT_FROM:-10000}"
TO="${TCP_PORT_TO:-19999}"
COOLDOWN=180
STATE_FILE="/tmp/find-free-tcp-port.state"
LOCK_FILE="/tmp/find-free-tcp-port.lock"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --from) FROM="$2"; shift 2 ;;
        --to)   TO="$2";   shift 2 ;;
        -h|--help)
            echo "Usage: find-free-tcp-port [--from PORT] [--to PORT]"
            echo "Find the next free TCP port in a range (default: 10000-19999)"
            echo "Recently returned ports are reserved for ${COOLDOWN}s"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Take an exclusive lock to prevent concurrent instances from reserving the same port
exec 9>"$LOCK_FILE"
flock 9

# Purge expired entries and load reserved ports
now=$(date +%s)
if [[ -f "$STATE_FILE" ]]; then
    fresh_entries=""
    while IFS=' ' read -r ts p; do
        if (( now - ts < COOLDOWN )); then
            fresh_entries+="$ts $p"$'\n'
        fi
    done < "$STATE_FILE"
    printf '%s' "$fresh_entries" > "$STATE_FILE"
fi

is_reserved() {
    [[ -f "$STATE_FILE" ]] && grep -q " $1\$" "$STATE_FILE"
}

for port in $(seq "$FROM" "$TO"); do
    if is_reserved "$port"; then
        continue
    fi
    if ! ss -tlnH "sport = :$port" 2>/dev/null | grep -q .; then
        echo "$(date +%s) $port" >> "$STATE_FILE"
        echo "$port"
        exit 0
    fi
done

echo "No free port found in range $FROM-$TO" >&2
exit 1
