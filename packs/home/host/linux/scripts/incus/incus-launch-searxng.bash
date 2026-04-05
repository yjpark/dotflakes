#!/usr/bin/env bash

# Launch the SearXNG incus container.
# SearXNG runs at 10.100.0.3, accessible via JSON API for agent web search.
# JSON API: http://10.100.0.3:8080/search?q=<query>&format=json

incus launch searxng searxng

# Static IP (referenced by incus-ingress.nix for dnsmasq and Caddy routing)
incus config device override searxng eth0 ipv4.address=10.100.0.3
