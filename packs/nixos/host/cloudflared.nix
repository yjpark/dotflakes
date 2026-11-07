{ flake, pkgs, ... }:
{
  services.cloudflared.package =
    flake.inputs.cloudflared-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.cloudflared;
}
