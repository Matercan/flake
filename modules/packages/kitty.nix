{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.kitty = (inputs.wrappers.wrapperModules.kitty.apply {
      inherit pkgs;

      settings = {
        font_family = "Fairfax SM";
        
        font_size = 12;
        background = "#eff1f5";
        foreground = "#5752b0";
        theme = "Catppuccin-Latte";
      };
    }).wrapper;
  };
}
