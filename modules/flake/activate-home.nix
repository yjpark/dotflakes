{ self, ... }:
let
  knownHosts = builtins.attrNames (builtins.readDir (self + /configurations/nixos));
in {
  perSystem = { self', pkgs, lib, ... }: {
    apps.default = {
      inherit (self'.packages.activate) meta;
      program = pkgs.writeShellApplication {
        name = "activate-home";
        text = ''
          set -x
          _host="$(hostname -s)"
          _user="$(id -un)"
          _key="''${_user}@''${_host}"
          _known="${lib.concatStringsSep " " knownHosts}"
          _found=0
          for h in $_known; do
            if [ "$_host" = "$h" ]; then _found=1; break; fi
          done
          if [ "$_found" = "0" ]; then
            echo "Host '$_host' not in known hosts, using fallback config '$_user@'"
            _key="$_user"@
          fi
          ${lib.getExe self'.packages.activate} "$_key"
        '';
      };
    };
  };
}
