#!/usr/bin/env bash

source `which color-logging`

set +eu

# https://github.com/upstash/context7#installation
# API key is injected by the OneCLI proxy running on the host (10.100.0.1:10255).
# Ensure HTTPS_PROXY and NODE_EXTRA_CA_CERTS are set before running Claude Code.
claude mcp add --scope project context7 -- npx -y @upstash/context7-mcp --api-key placeholder
