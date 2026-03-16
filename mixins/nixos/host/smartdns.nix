{...}: {
  services.smartdns = {
    enable = true;
    settings = {
      bind = ":1053";
      bind-tcp = ":1053";
      log-level = "info";
      log-size = "1M";
      log-num = "32";
      server-tls = [
        "8.8.8.8:853"
        "8.8.4.4:853"
        "1.1.1.1:853"
      ];
      server-https = [
        "https://cloudflare-dns.com/dns-query -exclude-default-group"
      ];
      server = [
        "223.5.5.5"
        "119.29.29.29"
        "114.114.114.114"
      ];
      speed-check-mode = "ping,tcp:80,tcp:443";
    };
  };
}
