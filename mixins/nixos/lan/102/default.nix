{ ... }: {
  imports = [ ../site.nix ];

  site = {
    id = "102";
    octet = 1;
    hosts = {
      "1" = "router";
      "5" = "p2 gpd-p2";
      "9" = "pc desktop";
      "10" = "mbp-2012";
      "11" = "mbp";
      "12" = "p2_wifi gpd-p2_wifi";
    };
  };
}
