{ inputs, ... }: {
  perSystem = {
    unfreePkgs, lib, system, ... 
  }:
  let
    spicePkgs = inputs.spicetify.legacyPackages.${system};
  in
  {
    packages.spicetify = inputs.spicetify.lib.mkSpicetify unfreePkgs {
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
