#!/usr/bin/env bash

source `which color-logging`

set +eu

# https://oraios.github.io/serena/02-usage/030_clients.html
claude mcp add --scope project serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context=claude-code --project-from-cwd
