{ ... }: {
  imports = [ ../site.nix ];

  site = {
    id = "708";
    octet = 7;
    hosts = {
      "1" = "router";
      "8" = "g1 hp-g1";
    };
  };
}
