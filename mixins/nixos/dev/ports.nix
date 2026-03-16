{...}: {
  services.firewalld.services.dev-ports = {
    ports = [
      { port = { from = 3000; to = 3999; }; protocol = "tcp"; }
      { port = { from = 8000; to = 8999; }; protocol = "tcp"; }
      { port = { from = 29000; to = 29999; }; protocol = "tcp"; }
    ];
  };
  services.firewalld.zones.public.services = [ "dev-ports" ];
}
