{ lib, ... }: {
  # Native PostgreSQL replaces the podman-onecli-postgres container.
  # OneCLI runs with --network=host so it shares this container's network
  # namespace and can connect to postgres via localhost and bind ports
  # directly on 10.100.0.2 (the static incus IP for this container).
  #
  # Static IP: set via `incus config device override onecli eth0 ipv4.address=10.100.0.2`
  # Dashboard: http://10.100.0.2:10254  (seeder API + management UI)
  # Proxy:     http://10.100.0.2:10255  (set HTTPS_PROXY in agent containers)
  #
  # After launch, the host-side onecli-init-ca-and-secrets service seeds secrets
  # into OneCLI and pushes the authenticated proxy URL to agent containers.

  services.postgresql = {
    enable = true;
    settings.listen_addresses = "localhost";
    ensureDatabases = [ "onecli" ];
    ensureUsers = [{
      name = "onecli";
      ensureDBOwnership = true;
    }];
    # Trust local and loopback connections (onecli container connects via TCP localhost)
    authentication = lib.mkOverride 10 ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
    '';
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.onecli = {
    image = "ghcr.io/onecli/onecli:latest";
    environment = {
      DATABASE_URL = "postgresql://onecli@127.0.0.1/onecli";
      GATEWAY_HOST = "10.100.0.2";
      GATEWAY_PORT = "10255";
      AUTH_MODE = "local";
    };
    volumes = [ "onecli-data:/app/data" ];
    extraOptions = [ "--network=host" ];
  };

  # Start onecli after postgres is ready; don't restart on nixos-rebuild switch
  systemd.services.podman-onecli = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    restartIfChanged = false;
  };

  # Expose OneCLI dashboard and proxy ports in the container's LAN zone
  services.firewalld.services.onecli = {
    ports = [
      { port = 10254; protocol = "tcp"; }
      { port = 10255; protocol = "tcp"; }
    ];
  };
  services.firewalld.zones.lan.services = [ "onecli" ];
}
