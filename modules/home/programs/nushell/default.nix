let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  contents = builtins.map (name:
    "\n# /* ------------ ${name} ------------\n" +
    builtins.readFile (targetDir + "/${name}") +
    "\n# */ ------------ ${name} ------------\n"
  ) files;
in
{
  programs.nushell = {
    enable = true;
    extraConfig = builtins.concatStringsSep "\n\n\n" contents;
  };
}
