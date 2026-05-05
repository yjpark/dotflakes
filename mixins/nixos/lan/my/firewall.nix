{...}: {
  services.firewalld.zones.lan = {
    sources = [ { address = "10.0.0.0/16"; } { address = "172.22.0.0/16"; } ];
    protocols = [ "icmp" ];
    ports = [
      { port = 22; protocol = "tcp"; }
      { port = 80; protocol = "tcp"; }
      { port = 443; protocol = "tcp"; }
      { port = { from = 1; to = 65535; }; protocol = "tcp"; }
      { port = { from = 1; to = 65535; }; protocol = "udp"; }
    ];
  };
}
