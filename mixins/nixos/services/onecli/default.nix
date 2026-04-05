{ pkgs, config, flake, ... }:
# OneCLI is an open-source MITM proxy gateway for AI agent credential management.
# Agents use placeholder API keys; OneCLI intercepts HTTPS and injects real credentials.
#
# OneCLI runs in the dedicated incus container at 10.100.0.2:
#   Dashboard:  http://10.100.0.2:10254
#   Proxy:      http://10.100.0.2:10255  (set HTTPS_PROXY in agent containers)
#
# AUTH_MODE=local means OneCLI auto-creates a hardcoded local admin (admin@localhost)
# with no OAuth setup needed. The seeder fetches the API key automatically via
# GET /api/auth/session then GET /api/user/api-key — no manual bootstrap required.
#
# Container proxy setup is declared in packs/nixos/container/onecli-proxy.nix.
# Secret injection config and reseed logic live in onecli-reseed.bash.
{
  # SOPS secrets for seeding
  sops.secrets."onecli-secrets" = {
    sopsFile = ../secrets/onecli-secrets.txt;
    format = "binary";
  };

  # Maintenance scripts (onecli-push-ca, onecli-list-secrets, onecli-reseed, etc.) co-located here
  environment.systemPackages =
    flake.inputs.autowire.gatherScriptPackages_bash pkgs ./.;
}
