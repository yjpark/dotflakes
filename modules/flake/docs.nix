{...}: {
  perSystem = {pkgs, ...}: {
    packages.docs = pkgs.stdenv.mkDerivation {
      name = "flakes-docs";
      src = ../../docs;
      nativeBuildInputs = [pkgs.mdbook];
      buildPhase = "mdbook build";
      installPhase = "mv book $out";
    };

    apps.docs-serve = {
      program = pkgs.writeShellApplication {
        name = "docs-serve";
        runtimeInputs = [pkgs.mdbook];
        text = ''
          mdbook serve "$(git rev-parse --show-toplevel)/docs"
        '';
      };
    };
  };
}
