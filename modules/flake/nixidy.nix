{ inputs, ... }:
{
  perSystem = { self', system, pkgs, lib, ... }: {
    packages.nixidy = inputs.nixidy.packages.${system}.default;
    devShells.nixidy = pkgs.mkShell {
      name = "nixidy";
      meta.description = "Shell environment for nixidy";
      buildInputs = [inputs.nixidy.packages.${system}.default];
      # Since my bash will automatically run fish, it's annoying for nix developer
      shellHook = "nu";
    };
    apps.nixidy = {
      program = pkgs.writeShellApplication {
        name = "run-nixidy";
        meta.description = "Run nixidy";
        text = ''
          set -x
          ${lib.getExe' self'.packages.nixidy "nixidy"}
        '';
      };
    };
  };
}
