{...}: {
  services.firewalld.settings.DefaultZone = "lan";
  services.firewalld.zones.lan = {
    interfaces = [ "eth0" ];
    sources = [ { address = "10.0.0.0/16"; } { address = "172.22.0.0/16"; } ];
    protocols = [ "icmp" ];
    ports = [
      { port = 80; protocol = "tcp"; }
      { port = 443; protocol = "tcp"; }
      { port = { from = 1000; to = 65535; }; protocol = "tcp"; }
      { port = { from = 1000; to = 65535; }; protocol = "udp"; }
    ];
  };
}
