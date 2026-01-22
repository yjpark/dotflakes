{flake, ...}: {
  imports = [
    flake.inputs.solaar.nixosModules.default
  ];
  services.solaar.enable = true;
}

