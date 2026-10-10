{ moduleWithSystem, ... }:
{
  flake.nixosModules.hyprlandConfiguration = moduleWithSystem (
    { pkgs, self', ... }:
    {
      networking = {
        hostName = "hyprland-btw";
        networkmanager.enable = true;
      };

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
