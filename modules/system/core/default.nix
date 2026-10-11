{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.core =
    {
      pkgs,
      system,
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

      environment.systemPackages =
        with pkgs;
        [
          vim
          curl
          wget
          inputs.tack.packages.${system}.default
        ]
        ++ (with self.packages.${system}; [
          bat
          zsh
          flamegraph
          git
        ]);

      system.stateVersion = "26.05";
    };
}
