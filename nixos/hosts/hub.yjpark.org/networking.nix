{ lib, ... }:

{
  networking = {
    nameservers = [ "100.100.2.136" "100.100.2.138" ];
    defaultGateway = "172.27.143.253";
    useDHCP = false;
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;

    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "172.27.128.6";
          prefixLength = 20;
        }
      ];
      ipv4.routes = [
        {
          address = "172.27.143.253";
          prefixLength = 32;
        }
      ];
    };
  };

  services.udev.extraRules = ''
    ATTR{address}=="00:16:3e:0c:4d:d8", NAME="eth0"
  '';
}
