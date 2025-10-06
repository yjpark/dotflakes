{
  description = "Autowire nix modules and other files";

  outputs = _: {
    default = import ./lib/default.nix;
    gatherImports = import ./lib/gatherImports.nix;
  };
}
