{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*".forwardAgent = true;
  };
}
