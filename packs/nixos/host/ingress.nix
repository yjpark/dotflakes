{ lib, ... }:
# Options for the host ingress hub (mixins/nixos/services/incus-ingress).
# Declared for every host so service modules (monitoring, clash, onecli) can
# register their links unconditionally; only hosts importing the mixin serve
# them.
let
  serviceType = lib.types.submodule ({ name, ... }: {
    options = {
      title = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Label shown on the hub page.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "Services";
        description = "Sidebar group on the hub page.";
      };
      upstream = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "127.0.0.1:8428";
        description = ''
          host:port to serve at https://<name>.<host>.<domain>, opened in the
          hub page's iframe. Null for links that are not web pages (MCP
          endpoints), which the page shows as a copyable URL instead.
        '';
      };
      path = lib.mkOption {
        type = lib.types.str;
        default = "/";
        description = "Path the hub page opens under the service's subdomain.";
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The link itself, for services without an upstream.";
      };
      note = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Short hint shown under the title.";
      };
    };
  });
in
{
  options.ingress = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "yjpark.org";
      description = ''
        Ingress domain. DNS: *.<host>.<domain> → the host's ZeroTier IP, one
        wildcard A record per host on Cloudflare.
      '';
    };

    containers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          ip = lib.mkOption { type = lib.types.str; };
          viaCaddy = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether the container runs packs/nixos/container/ingress.nix.
              If so, ports are reached through its Caddy (which also covers
              services bound to the container's localhost); otherwise the
              host proxies to <ip>:<port> directly.
            '';
          };
        };
      });
      default = [ ];
      description = ''
        Incus containers routed as <name>-<port>.<host>.<domain> and listed on
        the hub page. Each needs a static IP, assigned via
        `incus config device override <name> eth0 ipv4.address=<ip>`.
      '';
    };

    services = lib.mkOption {
      type = lib.types.attrsOf serviceType;
      default = { };
      description = "Host services listed on the hub page.";
    };

    sites = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "pc" "edger" ];
      description = "Hosts serving a hub page; the others are linked from each.";
    };
  };
}
