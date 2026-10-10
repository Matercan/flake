{ inputs, ... }: {
  perSystem = {
    pkgs, lib, system, ... 
  }:
  let
    spicePkgs = inputs.spicetify.legacyPackages.${system};
  in
  {
    packages.spicetify = inputs.spicetify.lib.mkSpicetify pkgs {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblockify
        hidePodcasts
        shuffle
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "macchiato";
    };
  };
}
