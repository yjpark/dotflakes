{...}: {
  services.firewalld.zones.lan = {
    sources = [ { address = "10.0.0.0/8"; } ];
    ports = [
      { port = { from = 1000; to = 65535; }; protocol = "tcp"; }
      { port = { from = 1000; to = 65535; }; protocol = "udp"; }
    ];
  };
}
