{ pkgs, lib, ... }:
let
  # beans — agentic-first issue tracker (https://github.com/hmans/beans).
  #
  # Upstream has no flake and the public release ships only the `beans` CLI
  # (which includes the `beans tui` subcommand); the `beans-serve` web UI is a
  # separate binary that is not published. Building from source is a two-stage
  # pnpm (SvelteKit frontend, embedded via //go:embed) + Go build. So we install
  # the prebuilt goreleaser release binary instead. See bean flakes-6ne0.
  #
  # To bump: change `version` and refresh `sha256` values from the release's
  # `beans_<version>_checksums.txt` asset.
  version = "0.4.2";

  sources = {
    x86_64-linux = {
      asset = "beans_Linux_x86_64.tar.gz";
      sha256 = "266d1e4dc7392c38131c4842c60cbd2f14d5e5f7a520bc297a9b9056fda7fcd0";
    };
    aarch64-linux = {
      asset = "beans_Linux_arm64.tar.gz";
      sha256 = "fc5ede1fd605963cd575d2577a9c8c3cf89abc8d60e9787a1f0390e2067f20df";
    };
    x86_64-darwin = {
      asset = "beans_Darwin_x86_64.tar.gz";
      sha256 = "fce4206affb0b5cca5d013e7bc856372521218ad1d381e455d17cde37fafbf32";
    };
    aarch64-darwin = {
      asset = "beans_Darwin_arm64.tar.gz";
      sha256 = "b0fc3be6d8cad16000ef7af2cfbd5fe780f6de3858e5bbe1d7d96dbe8d7e002a";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "beans: unsupported system ${system}");

  beans = pkgs.stdenv.mkDerivation {
    pname = "beans";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/hmans/beans/releases/download/v${version}/${src.asset}";
      inherit (src) sha256;
    };

    # Tarball has no top-level directory (LICENSE, README.md, beans).
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 beans $out/bin/beans
      runHook postInstall
    '';

    meta = {
      description = "Agentic-first issue tracker (beans CLI + TUI)";
      homepage = "https://github.com/hmans/beans";
      license = lib.licenses.asl20;
      platforms = builtins.attrNames sources;
      mainProgram = "beans";
    };
  };
in
{
  home.packages = [ beans ];
}
