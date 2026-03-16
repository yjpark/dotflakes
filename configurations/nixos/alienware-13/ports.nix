{ ... }: {
  services.firewalld.services.photoprism = {
    ports = [
      { port = 2342; protocol = "tcp"; } # photoprism
    ];
  };
  services.firewalld.zones.public.services = [ "photoprism" ];
}
