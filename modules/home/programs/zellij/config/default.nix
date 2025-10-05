let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  contents = builtins.map (name:
    "\n// /* ------------ ${name} ------------\n" +
    builtins.readFile (targetDir + "/${name}") +
    "\n// */ ------------ ${name} ------------\n"
  ) files;
in
{
  home.file.".config/zellij/config.kdl".text = builtins.concatStringsSep "\n\n\n" contents;
}
