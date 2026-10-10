{ moduleWithSystem, self, ... }:
{
  flake.nixosModules.hyprlandConfiguration = moduleWithSystem (
    { pkgs, system, ... }:
    {
      networking = {
        hostName = "hyprland-btw";
        networkmanager.enable = true;
      };

      environment.systemPackages = with pkgs; [
        kitty
      ] ++ (with self.packages.${system}; [
        hyprland
        nvim 
        nvim-config
      ]);

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-serif
        self.packages.${system}.firaCodeIScript
      ];

      xdg.portal = {
        enable = true;
        configPackages = [ self.packages.${system}.hyprland ];
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      imports = [ ./_hardware-configuration.nix ];
    }
  );
}
