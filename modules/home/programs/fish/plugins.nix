{ pkgs, ... }: {
  programs.fish.plugins = [
    {
      name = "replay";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "replay.fish";
        rev = "bd8e5b89ec78313538e747f0292fcaf631e87bd2";
        sha256 = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
      };
    }
    {
      name = "fishmarks";
      src = pkgs.fetchFromGitHub {
        owner = "yjpark";
        repo = "fishmarks";
        rev = "c40c83bfe9394f4c51f95f0fec7a3d801ac670f4";
        sha256 = "sha256-Czis1UrjS60sIq4CG1RHWoyqKqc7d1aaerGD1iFugpE=";
      };
    }
  ];
}
