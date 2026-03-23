{ pkgs, config, ... }: let
  # OneCLI is an open-source MITM proxy gateway for AI agent credential management.
  # Agents use placeholder API keys; OneCLI intercepts HTTPS and injects real credentials.
  #
  # Dashboard:   http://10.100.0.1:10254  (Incus bridge — accessible from containers)
  # Proxy:       http://10.100.0.1:10255  (set HTTPS_PROXY in agent containers)
  #
  # AUTH_MODE=local means OneCLI auto-creates a hardcoded local admin (admin@localhost)
  # with no OAuth setup needed. The seeder fetches the API key automatically via
  # GET /api/auth/session then GET /api/user/api-key — no manual bootstrap required.
  #
  # Container proxy setup is declared in mixins/nixos/container/onecli-proxy.nix.

  # Per-secret injection configuration.
  # Keys must match the names in the SOPS secrets file (onecli-secrets.txt).
  # Secrets not listed here get the _default config.
  secretConfigs = {
    _default = {
      hostPattern = "*";
      headerName = "x-api-key";
    };
    CONTEXT7_API_KEY = {
      hostPattern = "context7.com";
      headerName = "Authorization";
      valueFormat = "Bearer {value}";
    };
  };

  secretConfigsJson = pkgs.writeText "onecli-secret-configs.json"
    (builtins.toJSON secretConfigs);

  # Containers to push the authenticated proxy URL to after seeding.
  agentContainers = [ "yolo" ];

  seederScript = pkgs.writeShellApplication {
    name = "onecli-seed-secrets";
    runtimeInputs = with pkgs; [ curl gnugrep coreutils jq incus ];
    text = ''
      SECRETS_FILE="${config.sops.secrets."onecli-secrets".path}"
      CONFIG_FILE="${secretConfigsJson}"
      BASE_URL="http://10.100.0.1:10254"

      # Wait for OneCLI to be healthy
      for i in $(seq 1 30); do
        if curl -sf "$BASE_URL/healthz" > /dev/null 2>&1; then
          break
        fi
        echo "Waiting for OneCLI... ($i/30)"
        sleep 2
      done

      # Trigger local admin session creation and retrieve the API key.
      # AUTH_MODE=local auto-creates admin@localhost on first /api/auth/session call.
      echo "Fetching local admin API key..."
      curl -sf "$BASE_URL/api/auth/session" > /dev/null
      API_KEY=$(curl -sf "$BASE_URL/api/user/api-key" | jq -r '.apiKey')

      if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
        echo "ERROR: Could not retrieve API key from OneCLI"
        exit 1
      fi
      echo "Got API key: ''${API_KEY:0:8}..."

      echo "Seeding secrets into OneCLI..."

      while IFS='=' read -r key value; do
        [[ "$key" =~ ^# ]] && continue
        [[ -z "$key" ]] && continue

        # Look up per-secret config, fall back to _default
        secret_config=$(jq -r --arg k "$key" \
          'if .[$k] then .[$k] else ._default end' "$CONFIG_FILE")

        host_pattern=$(echo "$secret_config" | jq -r '.hostPattern')
        header_name=$(echo "$secret_config" | jq -r '.headerName')
        value_format=$(echo "$secret_config" | jq -r '.valueFormat // "{value}"')

        header_display="$header_name: ''${value_format/\{value\}/***}"
        echo "Seeding: $key (host=$host_pattern, injects '$header_display')"

        # Delete existing secret with the same name before re-seeding
        existing_id=$(curl -sf "$BASE_URL/api/secrets" \
          -H "Authorization: Bearer $API_KEY" | \
          jq -r --arg name "$key" '.[] | select(.name == $name) | .id // empty')
        if [[ -n "$existing_id" ]]; then
          curl -sf -X DELETE "$BASE_URL/api/secrets/$existing_id" \
            -H "Authorization: Bearer $API_KEY" && echo "Deleted existing: $key"
        fi

        curl -sf -X POST "$BASE_URL/api/secrets" \
          -H "Authorization: Bearer $API_KEY" \
          -H "Content-Type: application/json" \
          -d "$(jq -n \
            --arg name "$key" \
            --arg value "$value" \
            --arg hp "$host_pattern" \
            --arg hn "$header_name" \
            --arg vf "$value_format" \
            '{
              name: $name,
              type: "generic",
              value: $value,
              hostPattern: $hp,
              injectionConfig: { headerName: $hn, valueFormat: $vf }
            }')" && echo "OK: $key" || echo "ERROR: Failed to seed $key"
      done < "$SECRETS_FILE"

      echo "Done. Verify secrets at $BASE_URL"

      # Push authenticated proxy URL to agent containers so they can inject credentials.
      # Written to /etc/onecli-proxy-auth, sourced by /etc/profile.d/onecli-proxy.sh.
      PROXY_URL="http://x:''${API_KEY}@10.100.0.1:10255"
      AGENT_CONTAINERS=(${builtins.concatStringsSep " " agentContainers})
      for container in "''${AGENT_CONTAINERS[@]}"; do
        if incus list --format json | jq -e --arg n "$container" \
            '.[] | select(.name == $n) | select(.status == "Running")' > /dev/null 2>&1; then
          printf 'HTTPS_PROXY="%s"\nHTTP_PROXY="%s"\n' "$PROXY_URL" "$PROXY_URL" | \
            incus file push - "$container/etc/onecli-proxy-auth"
          echo "Pushed proxy auth to $container"
        else
          echo "Skipping proxy push to $container (not running)"
        fi
      done
    '';
  };
in {
  # Podman network for inter-container communication
  systemd.services.onecli-network = {
    description = "Create OneCLI podman network";
    before = [ "podman-onecli-postgres.service" "podman-onecli.service" ];
    requiredBy = [ "podman-onecli-postgres.service" "podman-onecli.service" ];
    # Don't restart on nixos-rebuild switch — network persists across updates.
    restartIfChanged = false;
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
        # Local mode: auto-creates admin@localhost, no OAuth/manual signup needed.
        # The seeder fetches the API key via /api/auth/session + /api/user/api-key.
        AUTH_MODE = "local";
      };
      volumes = [ "onecli-data:/app/data" ];
      ports = [
        "10.100.0.1:10254:10254"
        "10.100.0.1:10255:10255"
      ];
      extraOptions = [ "--network=onecli" ];
    };
  };

  # Don't restart containers on nixos-rebuild switch — they persist across updates.
  # Use `mise run restart-onecli` to explicitly restart when upgrading the image.
  systemd.services.podman-onecli.restartIfChanged = false;
  systemd.services.podman-onecli-postgres.restartIfChanged = false;

  # SOPS secrets for seeding
  sops.secrets."onecli-secrets" = {
    sopsFile = ./secrets/onecli-secrets.txt;
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
