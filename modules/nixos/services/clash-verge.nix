{...}: {
  services.firewalld.services.clash-verge = {
    ports = [
      { port = 1100; protocol = "tcp"; }
      { port = 1101; protocol = "tcp"; }
      { port = 1102; protocol = "tcp"; }
      { port = 1109; protocol = "tcp"; }
    ];
  };
  services.firewalld.zones.public.services = [ "clash-verge" ];
}
