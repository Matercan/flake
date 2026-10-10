{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.hyprlandConfiguration = moduleWithSystem (
    { pkgs, self', system, ... }:
    {
      networking = {
        hostName = "hyprland-btw";
        networkmanager.enable = true;
      };

      environment.systemPackages = with pkgs; [
        inputs.zen-browser.packages.${system}.default 
        kitty
      ] ++ (with self'.packages; [
        spicetify 
        hyprland
        nvim 
        nvim-config
      ]);

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-serif
        self'.packages.firaCodeIScript
      ];

      xdg.portal = {
        enable = true;
        configPackages = [ self'.packages.hyprland ];
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      imports = [ ./_hardware-configuration.nix ];
    }
  );
}
