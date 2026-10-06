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
        # a13 is at site 401 (10.0.4.0/24); it was previously at 10.0.1.x, and
        # the stale prefix here denied every client on its own LAN. 172.22. is
        # the ZeroTier range, so other hosts can reach the shares across sites.
        # TODO: derive these from the site mixin once mixins/nixos/lan/401 exists.
        "hosts allow" = "10.0.4. 172.22. 127.0.0.1 localhost";
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
