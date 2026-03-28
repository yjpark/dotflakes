{ lib, ... }: {
  # Container-specific git config for OneCLI proxy integration.
  # Rewrites SSH URLs to HTTPS so all git traffic routes through the OneCLI
  # MITM proxy on the host, which injects real credentials transparently.
  programs.git.settings.url."https://github.com/".insteadOf = "git@github.com:";

  # Override gh's credential helper with a dummy that returns placeholder creds.
  # Git needs credentials to proceed with the request; the OneCLI MITM proxy
  # then replaces the Authorization header with the real token.
  programs.git.settings.credential."https://github.com".helper = lib.mkForce
    "!printf 'username=x\\npassword=onecli-managed\\n'";

  # Prevent git from prompting for credentials interactively.
  # OneCLI handles auth injection; if it's down, fail fast instead of hanging.
  home.sessionVariables.GIT_TERMINAL_PROMPT = "0";

  # gh CLI requires a token to be set before it will make API requests.
  # Use a placeholder — OneCLI proxy replaces the Authorization header with
  # the real GITHUB_TOKEN for all github.com traffic.
  home.sessionVariables.GH_TOKEN = "onecli-managed";
}
