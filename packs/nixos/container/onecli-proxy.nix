{ pkgs, ... }: let
  # Rebuild /var/lib/ingress/ca-bundle.crt from system certs + OneCLI CA if present.
  # Runs at boot (after init-ingress-ca) and whenever the CA file is pushed/updated.
  # Idempotent: always rebuilds from scratch so no risk of double-appending.
  rebuildBundle = pkgs.writeShellScript "rebuild-onecli-ca-bundle" ''
    BUNDLE=/var/lib/ingress/ca-bundle.crt
    ONECLI_CA=/var/lib/onecli/ca.crt
    [ -f "$BUNDLE" ] || exit 0
    ${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt "$BUNDLE"
    if [ -f "$ONECLI_CA" ]; then
      ${pkgs.coreutils}/bin/cat "$ONECLI_CA" >> "$BUNDLE"
      echo "onecli-ca-bundle: appended OneCLI CA to bundle"
    fi
  '';
in {
  # Route agent HTTPS traffic through OneCLI for credential injection.
  # OneCLI intercepts HTTPS, injects real API keys, and forwards — agents use placeholder keys.
  #
  # OneCLI runs in the dedicated incus container at 10.100.0.2:
  #   Dashboard:  http://10.100.0.2:10254
  #   Proxy:      http://10.100.0.2:10255
  #
  # The authenticated proxy URL (http://x:<api_key>@10.100.0.2:10255) is written to
  # /etc/onecli-proxy-auth by the onecli-seed-secrets service on the host after each
  # nixos-rebuild switch. This file is sourced by the profile.d script below.
  #
  # The OneCLI CA cert is written to /var/lib/onecli/ca.crt by the host seeder.
  # The onecli-ca-bundle service and path unit keep the ingress CA bundle up to date
  # declaratively — no manual symlink mutations needed.

  # Stable directory for OneCLI CA cert written by the host seeder
  systemd.tmpfiles.rules = [ "d /var/lib/onecli 0755 root root -" ];

  # Rebuild the ingress CA bundle at boot (after init-ingress-ca initialises it)
  # and again whenever the cert file is pushed/updated by the seeder.
  systemd.services.onecli-ca-bundle = {
    description = "Rebuild ingress CA bundle with OneCLI CA if present";
    wantedBy = [ "multi-user.target" ];
    after = [ "init-ingress-ca.service" "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${rebuildBundle}";
    };
  };

  # Trigger onecli-ca-bundle.service whenever /var/lib/onecli/ca.crt is created or changed
  systemd.paths.onecli-ca-bundle = {
    description = "Watch for OneCLI CA cert";
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/var/lib/onecli/ca.crt";
  };

  environment.variables = {
    # Node.js needs its own CA config (doesn't use system trust store)
    NODE_EXTRA_CA_CERTS = "/var/lib/onecli/ca.crt";
    NODE_USE_ENV_PROXY = "1";
  };

  # Sources /etc/onecli-proxy-auth (written by host seeder) to set authenticated proxy URL.
  # For bash/POSIX login shells via profile.d:
  environment.etc."profile.d/onecli-proxy.sh".text = ''
    if [ -r /etc/onecli-proxy-auth ]; then
      . /etc/onecli-proxy-auth
      export HTTPS_PROXY HTTP_PROXY
    fi
  '';
  # Fish shell sourcing is handled by Home Manager in packs/home/container/onecli-proxy.nix.
}
