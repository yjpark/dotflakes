{ flake, lib, pkgs, ... }: {
  home.file =
    (lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/starship/")
    (flake.inputs.autowire.gatherFiles ".toml" ./.)) // {
      ".config/starship.toml".source = ./gruvbox-rainbow.toml;
    };

  programs.starship.enable = true;
}
