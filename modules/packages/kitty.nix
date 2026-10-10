{ inputs, ... }: {
  perSystem = {
    pkgs, ... 
  }: {
    packages.kitty = (inputs.wrappers.wrapperModules.kitty.apply {
      inherit pkgs;

      settings = {
        "font_family" = "FiraCodeiScript";
        "font_size" = 10;
        "background_opacity" = 0.8;
        "background" = "#363a4f";
        "foreground" = "#cad3f5";
      };
    }).wrapper;
  };
}
