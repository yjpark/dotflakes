{...}: {
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  services.firewalld.enable = true;
  services.firewalld.settings.DefaultZone = "public";
  services.firewalld.zones.public.services = [ "ssh" ];
}
