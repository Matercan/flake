{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.kitty = (inputs.wrappers.wrapperModules.kitty.apply {
      inherit pkgs;

      settings = {
        font_family = "W95FA";
        
        font_size = 10;
        background_opacity = 0.9;
        background = "#363a4f";
        foreground = "#cad3f5";
      };
    }).wrapper;
  };
}
