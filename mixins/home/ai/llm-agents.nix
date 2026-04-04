{
  flake,
  pkgs,
  ...
}:
let
    /*
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
    gastown = pkgs.buildGoModule rec {
      pname = "gastown";
      version = "0.13.0";
      src = pkgs.fetchFromGitHub {
        owner = "steveyegge";
        repo = "gastown";
        tag = "v${version}";
        hash = "sha256-6vN39HbUXavx6B4Xibi9kXN4MDMF3ftbftfFwp9WWHc=";
      };
      vendorHash = "sha256-A/BqG1/CXBLVJdICgTbcP2GO1M/MZfcCTWU3cYVbx9M=";
      subPackages = [ "cmd/gt" ];
      ldflags = [
        "-X github.com/steveyegge/gastown/internal/cmd.Version=v${version}"
        "-X github.com/steveyegge/gastown/internal/cmd.BuiltProperly=1"
      ];
      doCheck = false;
      postInstall = ''
        mkdir -p $out/share/fish/vendor_completions.d
        $out/bin/gt completion fish > $out/share/fish/vendor_completions.d/gt.fish
      '';
    };
    perles = pkgs.buildGoModule rec {
      pname = "perles";
      version = "0.8.2";
      src = pkgs.fetchFromGitHub {
        owner = "zjrosen";
        repo = "perles";
        tag = "v${version}";
        hash = "sha256-zyMXbgoVxQEU8gtRR/lklSzSpfT2wWACB5yxBfu9TfE=";
      };
      vendorHash = "sha256-xTvXuEsJNFxblMG7NQ27jG8e9DtNpFWp54QqlmjBMUU=";
      ldflags = [
        "-X main.version=v${version}"
      ];
      env.CGO_ENABLED = 0;
      doCheck = false;
    };
    */
    llm-agents = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

    /*
    # Re-wrap beads so bd finds our pinned dolt instead of the bundled 1.81.2
    beads = pkgs.runCommand "beads-custom-dolt" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      makeWrapper ${llm-agents.beads}/bin/.bd-wrapped $out/bin/bd \
        --prefix PATH : ${pkgs.lib.makeBinPath [ dolt ]}
    '';
    */
in
{
  programs.claude-code.package = llm-agents.claude-code;

  home.packages = [
    llm-agents.claude-code
    llm-agents.agent-browser
    llm-agents.rtk
    /*
    llm-agents.hermes-agent
    llm-agents.gemini-cli
    dolt
    beads
    gastown
    perles
    */
  ];
}
