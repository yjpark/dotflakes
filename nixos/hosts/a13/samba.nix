{ config, pkgs, ... }:

{
  # make shares visible for windows 10 clients
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "a13";
        "netbios name" = "a13";
        security = "user";
        #use sendfile = yes
        #max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        # Derived from the site mixin (mixins/nixos/lan/<site>) so moving a13
        # between sites cannot leave a stale prefix here denying its own LAN,
        # which is exactly what happened when it moved off 10.0.1.x.
        # 172.22. is ZeroTier, so other hosts reach the shares across sites.
        "hosts allow" = "${config.site.prefix} 172.22. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        path = "/data/public";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "yjpark";
        "force group" = "users";
      };
    };
  };
}
