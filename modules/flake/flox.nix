{inputs, ...}: {
  perSystem = {
    self',
    system,
    pkgs,
    lib,
    ...
  }: {
    devShells.flox = pkgs.mkShell {
      name = "flox";
      meta.description = "Shell environment for flox";
      buildInputs = [inputs.flox.packages.${system}.default];
      # Since my bash will automatically run fish, it's annoying for nix develop
      shellHook = "nu";
    };
    apps.flox = {
      program = pkgs.writeShellApplication {
        name = "run-flox";
        meta.description = "Run flox";
        text = ''
          set -x
          ${lib.getExe' self'.packages.flox "flox"}
        '';
      };
    };
  };
}
