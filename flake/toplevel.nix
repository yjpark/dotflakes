# Top-level flake glue
{...}: {
  perSystem = {
    pkgs,
    ...
  }: {
    formatter = pkgs.nixpkgs-fmt;
  };
}
