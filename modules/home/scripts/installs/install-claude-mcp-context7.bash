#!/usr/bin/env bash

source `which color-logging`

set +eu

# https://github.com/upstash/context7#installation
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key $1
