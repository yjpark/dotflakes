{flake, ...}: {
  imports = [
    flake.inputs.noctalia.homeModules.default
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      # https://docs.noctalia.dev/getting-started/nixos/#config-ref
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      colorSchemes.predefinedScheme = "Ayu";
      general = {
        radiusRatio = 0;
      };
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
