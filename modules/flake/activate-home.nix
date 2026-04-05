# Home Manager activation script
# Detects hostname, selects the right homeConfiguration, and activates it
{ inputs, ... }: {
  perSystem = { pkgs, lib, ... }:
  let
    readHostNames = dir:
      let entries = builtins.readDir (inputs.self + dir);
      in map (name:
        if entries.${name} == "regular" then lib.removeSuffix ".nix" name else name
      ) (builtins.filter (name: name != "default.nix" && name != ".gitkeep")
        (builtins.attrNames entries));
    hosts = readHostNames "/mixins/home/hosts";
    containers = readHostNames "/mixins/home/containers";
  in {
    apps.default = {
      type = "app";
      program = pkgs.writeShellApplication {
        name = "activate-home";
        runtimeInputs = [ pkgs.home-manager ];
        text = ''
          set -x
          _host="$(hostname -s)"
          _key=""
          _hosts=(${lib.concatStringsSep " " hosts})
          for h in "''${_hosts[@]}"; do
            if [ "$_host" = "$h" ]; then _key="yjpark@$_host"; break; fi
          done
          if [ -z "$_key" ]; then
            _containers=(${lib.concatStringsSep " " containers})
            for h in "''${_containers[@]}"; do
              if [ "$_host" = "$h" ]; then _key="yj@$_host"; break; fi
            done
          fi
          if [ -z "$_key" ]; then
            _user="$(id -un)"
            echo "Host '$_host' not in known hosts, using fallback config '$_user'"
            _key="''${_user}"
          fi
          echo "Activating home-manager config: $_key"
          _flake_root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || echo ".")"
          home-manager switch --flake "''${_flake_root}#''${_key}"
        '';
      };
    };
  };
}
