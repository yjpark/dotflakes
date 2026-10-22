{
  # MCP OAuth callback forward (bean flakes-q3l5, epic flakes-mqe9).
  #
  # Claude Code in the yolo container prints the authorize URL to the terminal
  # (packs/nixos/container/mcp-oauth-bridge.nix); the browser that opens it is
  # on the machine we ssh'd from, and the provider redirects it to
  # `http://localhost:3118/callback` there. Forward that port over the ssh
  # session into yolo, where mcp-oauth-bridge relays eth0:3118 to Claude Code
  # on 127.0.0.1:3118:
  #
  #   browser -> localhost:3118 -> ssh -> pc -> 10.100.0.100:3118 -> CC
  #
  # From WSL2, Windows' localhost:3118 reaches this forward through WSL's
  # localhost forwarding, so a Windows browser works too.
  #
  # Host profiles only: in containers Claude Code itself listens on 3118.
  # A second ssh session to pc just warns that the port is taken.
  programs.ssh.matchBlocks.mcp-oauth-pc = {
    host = "pc pc.* desktop desktop.* 172.22.1.9";
    localForwards = [
      {
        bind.port = 3118;
        host.address = "10.100.0.100";
        host.port = 3118;
      }
    ];
  };
}
