{ ... }: {
  # Route agent HTTPS traffic through OneCLI on the host for credential injection.
  # OneCLI intercepts HTTPS, injects real API keys, and forwards — agents use placeholder keys.
  #
  # OneCLI runs on the host at 10.100.0.1 (incusbr0 bridge):
  #   Dashboard:  http://10.100.0.1:10254
  #   Proxy:      http://10.100.0.1:10255
  #
  # The authenticated proxy URL (http://x:<api_key>@10.100.0.1:10255) is written to
  # /etc/onecli-proxy-auth by the onecli-seed-secrets service on the host after each
  # nixos-rebuild switch. This file is sourced by the profile.d script below.

  environment.variables = {
    NODE_EXTRA_CA_CERTS = "/usr/local/share/ca-certificates/onecli-ca.crt";
    NODE_USE_ENV_PROXY = "1";
  };

  # Sources /etc/onecli-proxy-auth (written by host seeder) to set authenticated proxy URL.
  environment.etc."profile.d/onecli-proxy.sh".text = ''
    if [ -r /etc/onecli-proxy-auth ]; then
      . /etc/onecli-proxy-auth
      export HTTPS_PROXY HTTP_PROXY
    fi
  '';
}
