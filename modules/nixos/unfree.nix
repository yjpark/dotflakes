{lib, ...}: {
  nixpkgs.config.allowUnfree = true;
  # TODO, merge multiple unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "displaylink"
    ];
}
