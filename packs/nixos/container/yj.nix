{ flake, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  baseConfigPath = self + /configurations/home/yj.nix;
  hostMixinDir = self + /mixins/home/containers;
  hostname = config.networking.hostName;
  hasHostMixinFile = builtins.pathExists (hostMixinDir + "/${hostname}.nix");
  hasHostMixinDir = builtins.pathExists (hostMixinDir + "/${hostname}");
  hostMixinPath = if hasHostMixinFile then hostMixinDir + "/${hostname}.nix" else hostMixinDir + "/${hostname}";
  hasHostMixin = hasHostMixinFile || hasHostMixinDir;
in {
  programs.fish.enable = true;

  users.extraUsers.yj = {
    isNormalUser = true;
    home = "/home/yj";
    description = "YJ";
    uid = 1000;
    extraGroups = ["wheel" "networkmanager" "disk" "systemd-journal" "input" "uinput"];
    shell = "/run/current-system/sw/bin/fish";
  };

  security.sudo.extraConfig = ''
    yj	ALL=(ALL) NOPASSWD: ALL

    Defaults env_keep += "http_proxy"
    Defaults env_keep += "https_proxy"
    Defaults env_keep += "all_proxy"
    Defaults env_keep += "NIX_CURL_FLAGS"
  '';

  nix.settings.trusted-users = ["yj"];

  home-manager.users.yj = {
      imports = [ baseConfigPath ]
        ++ lib.optional hasHostMixin hostMixinPath;
  };
}
