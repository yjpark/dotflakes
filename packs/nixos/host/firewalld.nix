{...}: {
  services.firewalld.settings.DefaultZone = "public";
  services.firewalld.zones.public.services = [ "ssh" ];
}
