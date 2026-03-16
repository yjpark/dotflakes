{pkgs, ...}: {
  # https://taoa.io/posts/Setting-up-ipad-screen-mirroring-on-nixos
  environment.systemPackages = with pkgs; [
    uxplay
    (pkgs.writeShellScriptBin "start-uxplay"  ''
      #!/usr/bin/env bash
      uxplay -p -hls -fs
    '')
  ];
  services.avahi = {
    nssmdns4 = true;
    enable = true;
    publish = {
      enable = true;
      userServices = true;
      domain = true;
    };
  };
  # https://github.com/FDH2/UxPlay?tab=readme-ov-file#2-uxplay-starts-but-stalls-after-initialized-server-sockets-appears-with-the-server-name-showing-on-the-client-but-the-client-fails-to-connect-when-the-uxplay-server-is-selected
  services.firewalld.services.uxplay = {
    ports = [
      { port = 7000; protocol = "tcp"; }
      { port = 7001; protocol = "tcp"; }
      { port = 7100; protocol = "tcp"; }
      { port = 6000; protocol = "udp"; }
      { port = 6001; protocol = "udp"; }
      { port = 7011; protocol = "udp"; }
    ];
  };
  services.firewalld.zones.public.services = [ "uxplay" ];
}
