{ ... }: {
  # Source OneCLI proxy auth for fish shell sessions.
  # The file is pushed by onecli-push-proxy-auth on the host.
  # Uses shellInit (not interactiveShellInit) so non-interactive shells also get proxy vars.
  programs.fish.shellInit = ''
    if test -r /etc/onecli-proxy-auth
      while read -l line
        set -l key (string replace -r '=.*' "" -- $line)
        set -l val (string replace -r '[^=]+="?(.*?)"?\s*$' '$1' -- $line)
        if test -n "$key" -a -n "$val"
          set -gx $key $val
        end
      end < /etc/onecli-proxy-auth
    end
  '';
}
