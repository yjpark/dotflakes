{...}: {
  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "565799d8f6457a8a" #yjpark
    ];
  };
  services.firewalld.services.zerotierone = {
    ports = [
      { port = 9993; protocol = "udp"; }
    ];
  };
  services.firewalld.zones.public.services = [ "zerotierone" ];
  services.firewalld.zones.trusted.sources = [ { address = "172.22.0.0/16"; } ];
}
