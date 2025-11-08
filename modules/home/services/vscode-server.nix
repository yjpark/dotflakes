{flake, ...}: {
  imports = [
    "${flake.inputs.nixos-vscode-server}/modules/vscode-server/home.nix"
  ];
  services.vscode-server.enable = true;
  services.vscode-server.enableFHS = true;

  # https://github.com/nix-community/nixos-vscode-server
  # need to have wget installed for vscode to download the binary
  # also need to run this to enable the service
  # systemctl --user enable auto-fix-vscode-server.service
  # systemctl --user start auto-fix-vscode-server.service
  #
  # may need to disable and enable again after update
  # systemctl --user disable auto-fix-vscode-server.service
}
