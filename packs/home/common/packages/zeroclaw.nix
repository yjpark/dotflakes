{ pkgs, lib, ... }:
let
  # ZeroClaw — self-hosted autonomous AI assistant runtime
  # (https://github.com/zeroclaw-labs/zeroclaw).
  #
  # nixpkgs ships zeroclaw but lags upstream (0.5.1 vs 0.8.2), and the upstream
  # flake compiles a large Rust workspace from source. So we install the
  # prebuilt goreleaser-style release binary instead (musl/static on Linux, no
  # patchelf needed). This installs the binaries only; runtime config
  # (~/.zeroclaw/config.toml, API-key secrets, optional service) is out of scope.
  # See bean flakes-kj17.
  #
  # To bump: change `version` and refresh `sha256` values from the release's
  # `SHA256SUMS` asset.
  version = "0.8.2";

  sources = {
    x86_64-linux = {
      asset = "zeroclaw-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "72ef78a7881d7439a3ca51763799eb50de6d109da2b3121dfe975f2242a623cd";
    };
    aarch64-linux = {
      asset = "zeroclaw-aarch64-unknown-linux-musl.tar.gz";
      sha256 = "f4106b4082e6a4806b0380a26c8cc7f1fd31245754baa0a19227eb280c10858f";
    };
    aarch64-darwin = {
      asset = "zeroclaw-aarch64-apple-darwin.tar.gz";
      sha256 = "506a320a5fe6605da1088a80d3ab02b2db59cfa947af0a83d25509d33715ba0e";
    };
  };

  inherit (pkgs.stdenv.hostPlatform) system;
  src = sources.${system} or (throw "zeroclaw: unsupported system ${system}");

  zeroclaw = pkgs.stdenv.mkDerivation {
    pname = "zeroclaw";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/zeroclaw-labs/zeroclaw/releases/download/v${version}/${src.asset}";
      inherit (src) sha256;
    };

    # Tarball has no top-level directory (zeroclaw, zerocode, web/dist/...).
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 zeroclaw $out/bin/zeroclaw
      # zerocode (companion TUI) ships in the same tarball; install if present.
      if [ -f zerocode ]; then
        install -Dm755 zerocode $out/bin/zerocode
      fi
      runHook postInstall
    '';

    meta = {
      description = "Self-hosted autonomous AI assistant runtime";
      homepage = "https://github.com/zeroclaw-labs/zeroclaw";
      license = with lib.licenses; [ mit asl20 ];
      platforms = builtins.attrNames sources;
      mainProgram = "zeroclaw";
    };
  };
in
{
  home.packages = [ zeroclaw ];
}
