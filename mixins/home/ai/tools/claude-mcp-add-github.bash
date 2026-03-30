#!/usr/bin/env bash

source `which color-logging`

set +eu

# https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md
# Uses the remote Streamable HTTP endpoint at api.githubcopilot.com.
# The Authorization header placeholder is replaced by the OneCLI proxy (10.100.0.1:10255),
# which injects the real GITHUB_COPILOT_TOKEN for api.githubcopilot.com traffic.
# Ensure HTTPS_PROXY and NODE_EXTRA_CA_CERTS are set before running Claude Code.
claude mcp add-json --scope project github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer onecli-managed"}}'
