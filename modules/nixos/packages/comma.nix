{pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nix-index
    comma             # run software without installing it (need nix-index)
    nix-search-cli
  ];
}

