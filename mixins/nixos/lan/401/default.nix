{ ... }: {
  imports = [ ../site.nix ];

  site = {
    id = "401";
    octet = 4;
    hosts = {
      "1" = "router";
      "2" = "edger";
      "3" = "imac";
      "5" = "p2 gpd-p2";
      "6" = "a13 alienware-13";
      "12" = "p2_wifi gpd-p2_wifi";
      "13" = "a13_wifi alienware-13_wifi";
    };
  };
}
