# browser-open <url>  (also installed as an `xdg-open` shim, and set as $BROWSER)
#
# Phase A of the MCP OAuth browser-open bridge (bean flakes-vzo1 / flakes-mqe9).
# Containers are headless — there is no local browser. Instead of trying to open
# one, surface the URL on the human's *terminal* as a clickable OSC 8 hyperlink,
# an OSC 52 clipboard copy, plain text, and a bell. Terminal escape sequences
# ride the live PTY back to wherever the human actually is (host desktop, or
# Windows Terminal via WSL/SSH), so this needs no knowledge of which access
# path is in use and it follows a zellij detach/reattach. One click to open.
#
# Written under `set -euo pipefail` (writeShellApplication).

# $BROWSER / xdg-open are always invoked as `cmd <url>`, so take the URL from
# the first argument. (No stdin fallback: reading stdin could block when the
# caller leaves a non-tty stdin open with no data.)
url="${1:-}"
if [ -z "$url" ]; then
  echo "browser-open: no URL given" >&2
  exit 1
fi

# Write to the controlling terminal, not stdout/stderr: the caller (Claude Code)
# captures the child's stdio, so only /dev/tty reaches the human. Fall back to
# stderr if there is no controlling terminal.
if [ -c /dev/tty ] && : > /dev/tty 2>/dev/null; then
  sink=/dev/tty
else
  sink=/dev/stderr
fi

esc=$(printf '\033')
bel=$(printf '\007')
st="${esc}\\" # OSC String Terminator: ESC backslash

# Everything goes out in a SINGLE redirection: $sink is opened once, so the
# stderr->file fallback can't truncate an earlier write (and /dev/tty is only
# opened once).
b64=$(printf '%s' "$url" | base64 | tr -d '\n')
link_text="🔗 Click to authorize (or paste the copied URL) in a browser"
{
  # OSC 52: copy the URL to the system clipboard (single-line base64).
  printf '%s]52;c;%s%s' "$esc" "$b64" "$st"
  # OSC 8 clickable hyperlink + plain URL + bell.
  printf '\n'
  printf '  %s]8;;%s%s%s%s]8;;%s\n' "$esc" "$url" "$st" "$link_text" "$esc" "$st"
  printf '  %s\n' "$url"
  printf '  ↑ copied to clipboard%s\n\n' "$bel"
} > "$sink"
