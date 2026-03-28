{ ... }: {
  # Container-specific git config for OneCLI proxy integration.
  # Rewrites SSH URLs to HTTPS so all git traffic routes through the OneCLI
  # MITM proxy on the host, which injects real credentials transparently.
  programs.git.settings.url."https://github.com/".insteadOf = "git@github.com:";

  # Provide placeholder credentials so git sends an Authorization header that
  # the OneCLI MITM proxy can intercept and replace with the real token.
  # Without this, git gets a 401 and gives up (GIT_TERMINAL_PROMPT=0).
  programs.git.settings.credential."https://github.com".helper = "!printf 'username=x\\npassword=onecli-managed\\n'";

  # Prevent git from prompting for credentials interactively.
  # OneCLI handles auth injection; if it's down, fail fast instead of hanging.
  home.sessionVariables.GIT_TERMINAL_PROMPT = "0";

  # gh CLI requires a token to be set before it will make API requests.
  # Use a placeholder — OneCLI proxy replaces the Authorization header with
  # the real GITHUB_TOKEN for all github.com traffic.
  home.sessionVariables.GH_TOKEN = "onecli-managed";
}
