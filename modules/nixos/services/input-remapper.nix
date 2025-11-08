{pkgs, ...}: {
  services.input-remapper.enable = true;
  environment.systemPackages = with pkgs; [
    input-remapper
  ];
}
