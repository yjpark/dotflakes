{pkgs, ...}: {
  # https://taoa.io/posts/Setting-up-ipad-screen-mirroring-on-nixos
  environment.systemPackages = with pkgs; [
    uxplay
    # Add GStreamer plugins for hardware decoding if needed (e.g., for NVIDIA/AMD)
    # gst_all_1.gst-plugins-bad
    # gst_all_1.gst-plugins-ugly
    # gst_all_1.gst-libav
  ];
  services.avahi = {
    nssmdns = true;
    enable = true;
    publish = {
      enable = true;
      userServices = true;
      domain = true;
    };
  };
  # https://github.com/FDH2/UxPlay?tab=readme-ov-file#2-uxplay-starts-but-stalls-after-initialized-server-sockets-appears-with-the-server-name-showing-on-the-client-but-the-client-fails-to-connect-when-the-uxplay-server-is-selected
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];
}
