{ ... }: {
  imports = [ ../site.nix ];

  site = {
    id = "102";
    octet = 1;
    hosts = {
      "1" = "router";
      "9" = "pc desktop";
      "10" = "mbp-2012";
      "11" = "mbp";
    };
  };
}
