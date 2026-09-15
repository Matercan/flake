{
  self,
  ...
}:
{
  flake.nixosModules.core =
    {
      pkgs,
      hostName,
      ...
    }:
    let
      inherit self;
      mods = self.nixosModules;
      bootloader = if hostName == "hyprland-btw" then mods.grub-boot else mods.systemd-boot;
      modules = with mods; [
        user
        bootloader
        nix
        locale
      ];
    in
    {
      imports = modules;

      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      environment.systemPackages = with pkgs; [
        vim
        unzip
        curl
        wget
      ];

      system.stateVersion = "26.05";
    };
}
