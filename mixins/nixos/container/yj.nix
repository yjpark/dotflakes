{
  programs.fish.enable = true;

  users.extraUsers.yjpark = {
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

  nix.settings.trusted-users = ["root" "yj"];
}
