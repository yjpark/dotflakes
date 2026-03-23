{ pkgs, config, ... }: let
  # OneCLI is an open-source MITM proxy gateway for AI agent credential management.
  # Agents use placeholder API keys; OneCLI intercepts HTTPS and injects real credentials.
  #
  # Dashboard:   http://10.100.0.1:10254  (Incus bridge — accessible from containers)
  # Proxy:       http://10.100.0.1:10255  (set HTTPS_PROXY in agent containers)
  #
  # Bootstrap process (first time only):
  # 1. After `nixos-rebuild switch`, visit http://10.100.0.1:10254 and create an admin account
  # 2. Generate an admin API key in the dashboard settings
  # 3. Encrypt the API key: echo "ONECLI_API_KEY=oc_xxx" | sops -e --input-type=dotenv > mixins/nixos/services/secrets/onecli-admin-key.txt
  # 4. Encrypt the secrets to seed: echo "CONTEXT7_API_KEY=xxx" | sops -e --input-type=dotenv > mixins/nixos/services/secrets/onecli-secrets.txt
  # 5. Rebuild again and run `systemctl start onecli-seed-secrets`
  #
  # Container proxy setup is declared in mixins/nixos/container/onecli-proxy.nix:
  #   HTTPS_PROXY=http://10.100.0.1:10255  (no token needed in URL)
  #   NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/onecli-ca.crt
  #   NODE_USE_ENV_PROXY=1

  seederScript = pkgs.writeShellApplication {
    name = "onecli-seed-secrets";
    runtimeInputs = with pkgs; [ curl gnugrep coreutils ];
    text = ''
      ADMIN_KEY_FILE="${config.sops.secrets."onecli-admin-key".path}"
      SECRETS_FILE="${config.sops.secrets."onecli-secrets".path}"

      API_KEY=$(grep -oP '(?<=ONECLI_API_KEY=).+' "$ADMIN_KEY_FILE")
      BASE_URL="http://127.0.0.1:10254"

      # Wait for OneCLI to be healthy
      for i in $(seq 1 30); do
        if curl -sf "$BASE_URL/healthz" > /dev/null 2>&1; then
          break
        fi
        echo "Waiting for OneCLI... ($i/30)"
        sleep 2
      done

      echo "Seeding secrets into OneCLI..."

      while IFS='=' read -r key value; do
        [[ "$key" =~ ^# ]] && continue
        [[ -z "$key" ]] && continue

        echo "Seeding: $key"
        curl -sf -X POST "$BASE_URL/api/secrets" \
          -H "Authorization: Bearer $API_KEY" \
          -H "Content-Type: application/json" \
          -d "{
            \"name\": \"$key\",
            \"type\": \"generic\",
            \"value\": \"$value\",
            \"hostPattern\": \"*\",
            \"injectionConfig\": {
              \"headerName\": \"x-api-key\"
            }
          }" && echo "OK: $key" || echo "WARN: Failed to seed $key (may already exist)"
      done < "$SECRETS_FILE"

      echo "Done. Verify secrets at $BASE_URL"
    '';
  };
in {
  # Podman network for inter-container communication
  systemd.services.onecli-network = {
    description = "Create OneCLI podman network";
    before = [ "podman-onecli-postgres.service" "podman-onecli.service" ];
    requiredBy = [ "podman-onecli-postgres.service" "podman-onecli.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network create onecli || true'";
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network rm -f onecli || true'";
    };
  };

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    onecli-postgres = {
      image = "postgres:17-alpine";
      environment = {
        POSTGRES_USER = "onecli";
        POSTGRES_PASSWORD = "onecli";
        POSTGRES_DB = "onecli";
      };
      volumes = [ "onecli-pgdata:/var/lib/postgresql/data" ];
      extraOptions = [ "--network=onecli" ];
    };

    onecli = {
      image = "ghcr.io/onecli/onecli:latest";
      dependsOn = [ "onecli-postgres" ];
      environment = {
        DATABASE_URL = "postgresql://onecli:onecli@onecli-postgres:5432/onecli";
        GATEWAY_HOST = "10.100.0.1";
        GATEWAY_PORT = "10255";
      };
      volumes = [ "onecli-data:/app/data" ];
      ports = [
        "10.100.0.1:10254:10254"
        "10.100.0.1:10255:10255"
      ];
      extraOptions = [ "--network=onecli" ];
    };
  };

  # SOPS secrets for seeding
  sops.secrets."onecli-secrets" = {
    sopsFile = ./secrets/onecli-secrets.txt;
    format = "binary";
  };

  sops.secrets."onecli-admin-key" = {
    sopsFile = ./secrets/onecli-admin-key.txt;
    format = "binary";
  };

  systemd.services.onecli-seed-secrets = {
    description = "Seed API secrets into OneCLI vault";
    after = [ "podman-onecli.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${seederScript}/bin/onecli-seed-secrets";
    };
  };

  # Convenience script to fetch and push the OneCLI CA cert into containers
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "onecli-push-ca";
      runtimeInputs = with pkgs; [ curl incus ];
      text = ''
        CONTAINERS=("''${@:-yolo}")
        CA_PEM=$(curl -sf http://10.100.0.1:10254/api/gateway/ca)

        for CONTAINER in "''${CONTAINERS[@]}"; do
          echo "Pushing OneCLI CA to $CONTAINER..."
          echo "$CA_PEM" | incus file push - "$CONTAINER/usr/local/share/ca-certificates/onecli-ca.crt"
          incus exec "$CONTAINER" -- update-ca-certificates
          echo "Done: $CONTAINER"
        done
      '';
    })
  ];

  # Explicitly open OneCLI ports on the incus bridge zone.
  # The incus zone already has target=ACCEPT, but this makes the intent explicit.
  services.firewalld.services.onecli = {
    ports = [
      { port = 10254; protocol = "tcp"; }  # Dashboard
      { port = 10255; protocol = "tcp"; }  # Proxy gateway
    ];
  };
  services.firewalld.zones.incus.services = [ "onecli" ];
}
