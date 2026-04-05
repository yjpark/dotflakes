{ ... }: {
  # SearXNG self-hosted meta-search engine for agent web search.
  #
  # Static IP: set via `incus config device override searxng eth0 ipv4.address=10.100.0.3`
  # JSON search API: http://10.100.0.3:8080/search?q=<query>&format=json
  # Caddy ingress routes: searxng-8080.<host>.yjpark.org → http://10.100.0.3:8080
  #
  # Internal LAN-only; not exposed to the internet — static secret key is acceptable.

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8080;
        bind_address = "0.0.0.0";
        # Static key is fine for a LAN-only instance (not publicly accessible).
        # Rotate by rebuilding if the container is ever exposed externally.
        secret_key = "searxng-internal-lan-only-secret-key";
        limiter = false;
        image_proxy = true;
      };
      search = {
        formats = [ "html" "json" ];
        safe_search = 0;
        default_lang = "en";
      };
      engines = [
        { name = "google"; engine = "google"; categories = "general"; shortcut = "g"; }
        { name = "bing"; engine = "bing"; categories = "general"; shortcut = "b"; }
        { name = "duckduckgo"; engine = "duckduckgo"; categories = "general"; shortcut = "d"; }
        { name = "wikipedia"; engine = "wikipedia"; shortcut = "w"; }
        { name = "github"; engine = "github"; categories = "it"; shortcut = "gh"; }
      ];
    };
  };
}
