{...}: {
  services.k3s = {
    enable = true;
    role = "server";
  };
  services.firewalld.services.k3s = {
    ports = [
      { port = 6443; protocol = "tcp"; }
      { port = 80; protocol = "tcp"; }
      { port = 443; protocol = "tcp"; }
      { port = { from = 30000; to = 32767; }; protocol = "tcp"; }
    ];
  };
  services.firewalld.zones.public.services = [ "k3s" ];
}
