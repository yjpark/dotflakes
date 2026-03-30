{
  flake,
  pkgs,
  ...
}:
let
    dolt-version = "1.83.5";
    dolt = pkgs.dolt.overrideAttrs (old: {
      version = dolt-version;
      src = pkgs.fetchFromGitHub {
        owner = "dolthub";
        repo = "dolt";
        tag = "v${dolt-version}";
        hash = "sha256-UaC9Yl3xl3IWQN7RSu1ApJNgm/fIgvLgoxOFWEVJK28=";
      };
      vendorHash = "sha256-hnJhLEJo/EQlTuTv+smiLok7AarFoDIB4ebB6ncUYtc=";
      doCheck = false;
    });
    mg = pkgs.buildGoModule rec {
      pname = "mardi-gras";
      version = "0.15.0";
      src = pkgs.fetchFromGitHub {
        owner = "quietpublish";
        repo = "mardi-gras";
        tag = "v${version}";
        hash = "sha256-YAXXXqa+4Qa3IkXZoipCOYSHjGpKXPKlBeJ+iV5Gdo8=";
      };
      vendorHash = "sha256-MaUxiDYWvn+q4yrtIhsTSSow4/WlAyKynMg5tUOt9VQ=";
      subPackages = [ "cmd/mg" ];
      doCheck = false;
    };
    llm-agents = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    # Re-wrap beads so bd finds our pinned dolt instead of the bundled 1.81.2
    beads = pkgs.runCommand "beads-custom-dolt" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      makeWrapper ${llm-agents.beads}/bin/.bd-wrapped $out/bin/bd \
        --prefix PATH : ${pkgs.lib.makeBinPath [ dolt ]}
    '';
in
{
  programs.claude-code.package = llm-agents.claude-code;

  home.packages = [
    llm-agents.claude-code
    llm-agents.gemini-cli
    llm-agents.agent-browser
    llm-agents.rtk
    beads
    dolt
    mg
  ];
}
