{ ... }: {
  # Route agent HTTPS traffic through OneCLI on the host for credential injection.
  # OneCLI intercepts HTTPS, injects real API keys, and forwards — agents use placeholder keys.
  #
  # OneCLI runs on the host at 10.100.0.1 (incusbr0 bridge):
  #   Dashboard:  http://10.100.0.1:10254
  #   Proxy:      http://10.100.0.1:10255
  #
  # After deploy: run `onecli-push-ca yolo` on the host to push the CA cert,
  # then configure injection rules in the OneCLI dashboard.
  environment.variables = {
    HTTPS_PROXY = "http://10.100.0.1:10255";
    HTTP_PROXY = "http://10.100.0.1:10255";
    NODE_EXTRA_CA_CERTS = "/usr/local/share/ca-certificates/onecli-ca.crt";
    NODE_USE_ENV_PROXY = "1";
  };
}
