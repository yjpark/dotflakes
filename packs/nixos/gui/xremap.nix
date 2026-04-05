{flake, ...}: {
  imports = [
    flake.inputs.xremap-flake.nixosModules.default
  ];
  services.xremap = {
    enable = true;
    serviceMode = "user";
    userName = "yjpark";
    mouse = true;
    withNiri = true;
    #withCosmic = true;
    config.modmap = [
      {
        name = "Mouse buttons";
        remap = {
          "BTN_5" = "SUPER_L";
          "BTN_BACK" = "KEY_VOLUMEDOWN";
          "BTN_FORWARD" = "KEY_VOLUMEUP";
          "BTN_8" = "KEY_VOLUMEDOWN";
          "BTN_9" = "KEY_VOLUMEUP";
        };
      }
    ];
  };
}
