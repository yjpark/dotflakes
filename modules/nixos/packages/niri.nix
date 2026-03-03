{
  flake,
  pkgs,
  ...
}: let
  # 1. Define your special launcher script
  start-cosmic-ext-niri = pkgs.writeShellScriptBin "start-cosmic-ext-niri" (builtins.readFile ./niri-cosmic/start-cosmic-ext-niri.bash);

  # 2. Create a desktop file that points to your script
  niriCosmicSession = pkgs.writeTextDir "share/wayland-sessions/niri-Cosmic.desktop" ''
    [Desktop Entry]
    Name=Niri Cosmic
    Comment=A scrollable-tiling Wayland compositor (with Cosmic session)
    Exec=${start-cosmic-ext-niri}/bin/start-cosmic-ext-niri
    Type=Application
  '';

  cosmic-ext-alternative-startup = pkgs.stdenv.mkDerivation {
    pname = "cosmic-ext-alternative-startup";
    version = "1.0.0";

    # Point this to the DIRECTORY containing your binary
    # Nix will copy the contents of this directory to the build environment
    src = ./niri-cosmic;

    # autoPatchelfHook is the magic that makes standard Linux binaries work on NixOS
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    # Add any shared libraries your binary needs to run here.
    # stdenv.cc.cc.lib provides the standard C/C++ libraries (libstdc++, etc.)
    # If your binary requires Wayland or xkbcommon, add pkgs.wayland or pkgs.libxkbcommon
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
    ];

    # We skip the unpacking/building steps since it's already a compiled binary
    dontUnpack = true;
    dontBuild = true;

    # Simply copy the binary to the output's bin directory and make it executable
    installPhase = ''
      mkdir -p $out/bin

      cp $src/cosmic-ext-alternative-startup $out/bin/cosmic-ext-alternative-startup

      chmod +x $out/bin/cosmic-ext-alternative-startup
    '';
  };
in {
  # 3. Tell the display manager to include this session
  services.displayManager.sessionPackages = [niriCosmicSession];

  environment.systemPackages = with pkgs; [
    flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri
    start-cosmic-ext-niri
    cosmic-ext-alternative-startup
  ];
}
