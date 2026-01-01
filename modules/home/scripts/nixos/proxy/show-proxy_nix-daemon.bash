#!/usr/bin/env bash

sudo systemctl cat nix-daemon | grep _proxy
sudo systemctl cat nix-daemon | grep NIX_CURL_FLAGS