{flake, ...}: {
  imports = [
    flake.inputs.noctalia.homeModules.default
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      bar = {
        density = "compact";
      };
    };
  };
}
