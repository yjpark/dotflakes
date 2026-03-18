#!/usr/bin/env bash

source `which color-logging`

set +eu

# https://github.com/BeaconBay/ck
claude mcp add ck-search -s user -- ck --serve
