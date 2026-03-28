{ ... }: {
  # Container-specific git config for OneCLI proxy integration.
  # Rewrites SSH URLs to HTTPS so all git traffic routes through the OneCLI
  # MITM proxy on the host, which injects real credentials transparently.
  programs.git.settings.url."https://github.com/".insteadOf = "git@github.com:";

  # Force git to send proxy credentials (Basic auth) on the initial CONNECT request.
  # Without this, git opens an unauthenticated tunnel and OneCLI can't identify
  # the agent — so it passes traffic through without MITM/header injection.
  programs.git.settings.http.proxyAuthMethod = "basic";

  # Disable gh's credential helper — OneCLI proxy handles auth injection.
  # Without this, gh adds `gh auth git-credential` which uses the placeholder
  # GH_TOKEN and fails, causing "could not read Username" errors.
  programs.gh.gitCredentialHelper.enable = false;

  # Prevent git from prompting for credentials interactively.
  # OneCLI handles auth injection; if it's down, fail fast instead of hanging.
  home.sessionVariables.GIT_TERMINAL_PROMPT = "0";

  # gh CLI requires a token to be set before it will make API requests.
  # Use a placeholder — OneCLI proxy replaces the Authorization header with
  # the real GITHUB_TOKEN for all github.com traffic.
  home.sessionVariables.GH_TOKEN = "onecli-managed";
}
