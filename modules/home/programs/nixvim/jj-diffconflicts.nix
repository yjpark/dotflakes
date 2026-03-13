{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "jj-diffconflicts";
      src = pkgs.fetchFromGitHub {
        owner = "rafikdraoui";
        repo = "jj-diffconflicts";
        rev = "2b8431c014bbf764e97b82567e30da52e3b00c1f";
        hash = "sha256-nzjRWHrE2jIcaDoPbixzpvflrtLhPZrihOEQWwqqU0s=";
      };
    })
  ];
}
