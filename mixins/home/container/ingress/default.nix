{ pkgs
, ...
}:
let
  generate-ingress-config = pkgs.writeShellApplication {
    name = "generate-ingress-config";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname systemd coreutils jq gnugrep ];
    text = builtins.readFile ./generate-ingress-config.bash;
  };

  ingress = pkgs.writeShellApplication {
    name = "ingress";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname gnugrep ];
    text = builtins.readFile ./ingress.bash;
  };

  ingress-sync = pkgs.writeShellApplication {
    name = "ingress-sync";
    runtimeInputs = with pkgs; [ systemd ];
    text = builtins.readFile ./ingress-sync.bash;
  };

  ingress-sync-api = pkgs.writeScriptBin "ingress-sync-api" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./ingress-sync-api.py}
  '';

  ingress-hub-html = pkgs.runCommand "ingress-hub-html" { } ''
    mkdir -p $out/share/ingress
    cp ${./hub-index.html} $out/share/ingress/hub-index.html
  '';
in
{
  home.packages = [
    generate-ingress-config
    ingress
    ingress-sync
    ingress-sync-api
    ingress-hub-html
  ];
}
