{
  # ZeroTier addresses are flat and site-independent: these names resolve and
  # route from any site, which is why mixins/nixos/lan/<site> only carries its
  # own subnet. See mixins/nixos/lan/site.nix.
  #
  # x1 (thinkpad-x1) is intentionally absent: it is still in use and may show up
  # at any site, but it is a Windows laptop so it is not managed from here.
  networking.extraHosts = ''
    172.22.1.2    edger.yjpark.zerotier
    172.22.1.3    imac.yjpark.zerotier
    172.22.1.5    p2.yjpark.zerotier gpd-p2.yjpark.zerotier
    172.22.1.6    a13.yjpark.zerotier alienware-13.yjpark.zerotier
    172.22.1.8    g1.yjpark.zerotier hp-g1.yjpark.zerotier
    172.22.1.9    pc.yjpark.zerotier desktop.yjpark.zerotier
    172.22.1.10   mbp-2012.yjpark.zerotier
    172.22.1.11   mbp.yjpark.zerotier
    172.22.1.12   p2_wifi.yjpark.zerotier gpd-p2_wifi.yjpark.zerotier
    172.22.1.13   a13_wifi.yjpark.zerotier alienware-13_wifi.yjpark.zerotier
  '';
}
