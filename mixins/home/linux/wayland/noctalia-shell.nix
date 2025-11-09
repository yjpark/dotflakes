{flake, ...}: {
  imports = [
    flake.inputs.noctalia.homeModules.default
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      colorSchemes.predefinedScheme = "Ayu";
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      bar = {
        density = "default";
      };
      dock = {
        enable = false;
      };
      location = {
        monthBeforeDay = true;
        name = "Shanghai, China";
      };
    };
  };
}
