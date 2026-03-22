{...}: {
  services.firewalld.settings.DefaultZone = "lan";
  services.firewalld.zones.lan = {
    interfaces = [ "eth0" ];
    sources = [ { address = "10.0.0.0/16"; } ];
    ports = [
      { port = { from = 1000; to = 65535; }; protocol = "tcp"; }
      { port = { from = 1000; to = 65535; }; protocol = "udp"; }
    ];
  };
}
