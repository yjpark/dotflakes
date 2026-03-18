{ flake, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  baseConfigPath = self + /configurations/home/yjpark.nix;
  hostMixinDir = self + /mixins/home/hosts;
  hostname = config.networking.hostName;
  hasHostMixin = builtins.pathExists (hostMixinDir + "/${hostname}.nix");
in {
  programs.fish.enable = true;

  users.extraUsers.yjpark = {
    isNormalUser = true;
    home = "/home/yjpark";
    description = "YJ Park";
    uid = 1000;
    extraGroups = ["wheel" "networkmanager" "disk" "systemd-journal" "input" "uinput"];
    shell = "/run/current-system/sw/bin/fish";

    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGcPrgir2t1e1XRKcR8Pc0qUPRx2mhOHVdm5htMxNvT2/S3saXoY3px1pPH2tn3xan4SezfhpUZ7nwHnZwRcU/gHQHavZp0NhVL0zXBjj9TJwI323n7ND3C/1D+5cf7vg/PQpqf4tjBfN4gUPx2kp6Wa7c7ykVxv2upegQlyydPL1W1mA== yjpark-desktop_2020-09-14"
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACKdEBO0wXvyuZCCXqpSu3Q+9Kevmqytqf3o5tCajj6wpGQOrlCRHC9WE17WV1rwo8JiRVm/LgUuNGzdzeo3KKqnQCpXyYsw4LB3wxCqyaet7tupDGoyqi3Oyade//DbB7yEU91GBezRhSqEZincmr01Jn1VBxcR+1KufGRJKHPPfvY/w== yjpark-g1_2020-09-16"
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAwb1fKIbHSGY1xdIb+vu5bOulrnoZdvXa6x/CmOHSOpjxapMtnrH5lBOwnNWvJ3Fbt5QY7m2fJDXyy7C6rbri7iwE4X3LvQh1eyMuEIYRkuzQTK2cstD4pqBgW0zqcAMpp929F+jm4WWpl+eLFLTUZLaB78wSVK6fgJczODLGtd2dEfA== yjpark-ipad-pro-11_2022-02-17"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeu37LVryVQqQHc+7WIHWHD0rdkbFNvuiZcWEjCD5odkMIft7uTxdwuy9gj/9qy62Qa+4MuBOf3Z5Z4VEmU+2ptgiPO8mHw1b1Du4BJMdOQbXSIKdhfxDelZ3+GUV8w/9prnW196NIJDblhaOJPHJYGAmQtVoYKJ1AGiPlD/bUP0ZmiiAxs1TnOsnOHA75gfIqGrtcaIHtbgdzyx52LpAg2BgG1id4gGM09osXc0jHHlzT2GdcJtHsQhaF48MLoRtis1lz1p9gI3M4UczmWoFKK5Trfu4jkjCFZApaL+RjfAOz/lTUIzwf0F3Nskpv3wWmfGYw0leciXGD634v5pRl yjpark_mbp_2016-11-10"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi7njMNFh4AMAONEZcKLAFQV5Ir5EUBzLt5YJni4E33ujdMbJzj6u3VKg3yNaHiMVgVFvE8D087ANBL3dAgu2B0aasusYkeOTI8krjTAT0qdVEE6Kb8u1zjJTWmZ6i8QS1EYJu50SzNh2yPp8MWo7YU3/WI4n6qZqUfouubdL9l2hrfrzhcRCxVamtX37Uxc9HfQOCZsMk9p3SZUszASOysmFazrbBrrLDBnGjbx1dHp09z56GFlmOyavyBY/OWDctu1xYPJOmukTPKoLySBFfdxpmUK03+BsfWVVV3QAYe5lZr0c4o/bwIHsBTTHOPV6vbhTuw8QJ+btldtBwkE9h yjpark_office_2016-11-31"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/qshPgTnY/dfPdM8LVKfevnKvszBCeNv31tFD7QMGyuWL1j0myBaSFW3gQ7actBK0Wn6lltRPewONUDD/byJE+I5tUr8YtwZB4V6Hje1tcACIj8QzOSLWWbpxEYk0w37qWBIz63YePv0R4jM2BkUd6oGtYkuzMyk5xZKj1KUgeSJ+SNAc0eNNRa+nJNoAWetv44pPFER3Wwv56bcUhjwvPMi+dLszR4KcdaAoJPQcPgK+pneyGDldI1XFjaF6EYIOXVvjDgYcocbM+ZM1NM6VsoXQrIdwzvuoxYX4Lcqx9fmY7wzXpj0MEj1xMQF9Zo5ctvmhlrRUnDu5DQJjfnNcuDZ25WNtsWF2tJFyhezB0Jv7PusD+8D+1whNdSWlNH2MnNt9SZIDcQNE7BFspsl87SDl76YF0uFAnO256M7x648KJJsuZBKhONFWaCgmCEVkMGgBrhszuhYfLQ9ImME+4flS/TIWkxbOCZ5TZwVjeCH5c7aP6/ZoZgdvFu5bXu8= yjpark_my_2024-12-12"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHx49952O1xbZwGhVDvCGTtzirDV7IJD98rzQVJEhhjK yjpark_my_2024-12-26"
    ];
  };

  security.sudo.extraConfig = ''
    yjpark	ALL=(ALL) NOPASSWD: ALL

    Defaults env_keep += "http_proxy"
    Defaults env_keep += "https_proxy"
    Defaults env_keep += "all_proxy"
    Defaults env_keep += "NIX_CURL_FLAGS"
  '';

  nix.settings.trusted-users = ["yjpark"];

  home-manager.users.yjpark = {
      imports = [ baseConfigPath ]
        ++ lib.optional hasHostMixin (hostMixinDir + "/${hostname}.nix");
  };
}
