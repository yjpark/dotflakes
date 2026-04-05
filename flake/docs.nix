{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages.docs = pkgs.stdenv.mkDerivation {
      name = "flakes-docs";
      srcs = [
        ../../docs
        ../../.beans.yml
        ../../.beans
      ];
      sourceRoot = ".";
      nativeBuildInputs = [
        pkgs.mdbook
        inputs.mdbook-beans.packages.${system}.default
      ];
      unpackPhase = ''
        for src in $srcs; do
          name=$(stripHash "$src")
          cp -r "$src" "$name"
        done
        chmod -R u+w docs/
      '';
      buildPhase = "mdbook build docs/";
      installPhase = "mv docs/book $out";
    };

    apps.docs-serve = {
      program = pkgs.writeShellApplication {
        name = "docs-serve";
        runtimeInputs = [
          pkgs.mdbook
          inputs.mdbook-beans.packages.${system}.default
        ];
        text = ''
          mdbook serve "$(git rev-parse --show-toplevel)/docs" "$@"
        '';
      };
    };
  };
}
