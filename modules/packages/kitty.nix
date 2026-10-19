{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.kitty = (inputs.wrappers.wrapperModules.kitty.apply {
      inherit pkgs;

      settings = {
        font_family = "Fairfax SM";
        
        font_size = 12;
        background_opacity = 0.9;
        background = "#363a4f";
        foreground = "#cad3f5";
      };
    }).wrapper;
  };
}
