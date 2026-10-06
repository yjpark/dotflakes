{ config, lib, ... }:
# Per-site LAN facts. Each mixins/nixos/lan/<site> imports this module and fills
# in the data; everything derived from it — the /etc/hosts entries and the
# firewalld lan zone — lives here so it is written once rather than per site.
#
# The site id doubles as the mixin directory name, and its leading digit is the
# third octet of the subnet:
#   102 -> 10.0.1.0/24   401 -> 10.0.4.0/24   708 -> 10.0.7.0/24
#
# Cross-site access deliberately does not use these names. packs/nixos/host/
# zerotier provides <host>.yjpark.zerotier -> 172.22.1.x, which resolves and
# routes from anywhere, so each site lists only its own subnet and a bare name
# can never resolve to an address that does not route.
let
  cfg = config.site;
in
{
  options.site = {
    id = lib.mkOption {
      type = lib.types.str;
      example = "401";
      description = "Site identifier, also the mixin directory name.";
    };

    octet = lib.mkOption {
      type = lib.types.ints.u8;
      example = 4;
      description = "Third octet of this site's 10.0.N.0/24 subnet.";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "2" = "edger";
        "6" = "a13 alienware-13";
      };
      description = ''
        Host part of the address mapped to its names, for this site only.
        Host parts are stable across sites: a machine keeps its last octet and
        only the site octet changes.
      '';
    };

    prefix = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = ''Address prefix for this site, e.g. "10.0.4.".'';
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = ''CIDR for this site, e.g. "10.0.4.0/24".'';
    };
  };

  config = {
    site.prefix = "10.0.${toString cfg.octet}.";
    site.subnet = "${cfg.prefix}0/24";

    networking.extraHosts = lib.concatStringsSep "\n" (
      map (host: "${cfg.prefix}${host}\t${cfg.hosts.${host}}")
        (lib.sort (a: b: lib.toInt a < lib.toInt b) (lib.attrNames cfg.hosts))
    );

    # Narrowed from the previous blanket 10.0.0.0/16 to this site's own /24.
    # Cross-site traffic arrives over ZeroTier, which the host configs already
    # place in the trusted zone, so nothing legitimate needed the wider range.
    services.firewalld.zones.lan = {
      sources = [{ address = cfg.subnet; }];
      protocols = [ "icmp" ];
      ports = [
        { port = 22; protocol = "tcp"; }
        { port = 80; protocol = "tcp"; }
        { port = 443; protocol = "tcp"; }
        { port = { from = 1; to = 65535; }; protocol = "tcp"; }
        { port = { from = 1; to = 65535; }; protocol = "udp"; }
      ];
    };
  };
}
