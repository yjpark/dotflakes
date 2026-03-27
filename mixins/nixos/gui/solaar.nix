# Logitech device manager — use Solaar to set scroll wheel to ratchet mode
# to prevent accidental tab switching in Chrome when moving the mouse over the tab bar.
{flake, pkgs, ...}: {
  imports = [
    flake.inputs.solaar.nixosModules.default
  ];
  services.solaar.enable = true;
  services.udev.packages = [ pkgs.solaar ];
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}

