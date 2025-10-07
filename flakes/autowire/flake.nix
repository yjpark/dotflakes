{
  description = "Autowire nix modules and other files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs:
  let
    lib = inputs.nixpkgs.lib;
    gatherNames = import ./lib/gatherNames.nix;
    gatherFiles = import ./lib/gatherFiles.nix;
    gatherExecutables = import ./lib/gatherExecutables.nix;
    gatherScriptPackages = import ./lib/gatherScriptPackages.nix;
    gatherContents = import ./lib/gatherContents.nix;
    concatContents = import ./lib/concatContents.nix;
  in
  {
    default = import ./lib/default.nix;
    doPrefixName = import ./lib/doPrefixName.nix;
    gatherImports = import ./lib/gatherImports.nix;

    gatherNames = gatherNames lib;
    gatherFiles = gatherFiles lib;
    gatherContents = gatherContents lib;
    gatherExecutables = gatherExecutables lib;
    gatherScriptPackages = gatherScriptPackages lib;

    gatherFiles_fish = gatherFiles lib ".fish";
    gatherExecutables_fish = gatherExecutables lib ".fish";
    gatherScriptPackages_fish = gatherScriptPackages lib ".fish";
    gatherContents_fish = gatherContents lib ".fish";
    concatContents_fish = concatContents lib ".fish" "#" "\n\n\n";

    gatherFiles_bash = gatherFiles lib ".bash";
    gatherExecutables_bash = gatherExecutables lib ".bash";
    gatherScriptPackages_bash = gatherScriptPackages lib ".bash";
    gatherContents_bash = gatherContents lib ".bash";
    concatContents_bash = concatContents lib ".bash" "#" "\n\n\n";

    gatherFiles_nu = gatherFiles lib ".nu";
    gatherExecutables_nu = gatherExecutables lib ".nu";
    gatherContents_nu = gatherContents lib ".nu";
    concatContents_nu = concatContents lib ".nu" "#" "\n\n\n";

    gatherFiles_kdl = gatherFiles lib ".kdl";
    gatherContents_kdl = gatherContents lib ".kdl";
    concatContents_kdl = concatContents lib ".kdl" "#" "\n\n\n";

    gatherFiles_wasm = gatherFiles lib ".wasm";
  };
}
