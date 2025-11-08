{...}: {
  services.nix-serve = {
    enable = true;
    openFirewall = true;
    port = 1050;
    extraParams = "--access-log /tmp/nix-serve.log";
  };
}
