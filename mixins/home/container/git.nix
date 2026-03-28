{ lib, ... }: {
  # Container-specific git config for OneCLI proxy integration.
  # Rewrites SSH URLs to HTTPS so all git traffic routes through the OneCLI
  # MITM proxy on the host, which injects real credentials transparently.
  programs.git.settings.url."https://github.com/".insteadOf = "git@github.com:";

  # Disable gh's credential helper for github.com so git sends requests
  # without an Authorization header — the OneCLI proxy injects the real token.
  # (gh sets credential."https://github.com".helper by default; override to empty.)
  programs.git.settings.credential."https://github.com".helper = lib.mkForce "";

  # Prevent git from prompting for credentials interactively.
  # OneCLI handles auth injection; if it's down, fail fast instead of hanging.
  home.sessionVariables.GIT_TERMINAL_PROMPT = "0";

  # gh CLI requires a token to be set before it will make API requests.
  # Use a placeholder — OneCLI proxy replaces the Authorization header with
  # the real GITHUB_TOKEN for all github.com traffic.
  home.sessionVariables.GH_TOKEN = "onecli-managed";
}
