{...}: {
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  services.firewalld.enable = true;
}
