{flake, ...}: {
  imports = [
    flake.inputs.xremap-flake.nixosModules.default
  ];
  services.xremap = {
    enable = true;
    serviceMode = "user";
    userName = "yjpark";
    withNiri = true;
    withCosmic = true;
    config.modmap = [
      {
        name = "Mouse buttons";
        remap = {
          "BTN_MIDDLE" = "SUPER_L";
          "BTN_8" = "KEY_VOLUMEDOWN";
          "BTN_9" = "KEY_VOLUMEUP";
        };
      }
    ];
  };
}
