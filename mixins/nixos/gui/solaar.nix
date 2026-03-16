{flake, pkgs, ...}: {
  imports = [
    flake.inputs.solaar.nixosModules.default
  ];
  services.solaar.enable = true;
  services.udev.packages = [ pkgs.solaar ];
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}

