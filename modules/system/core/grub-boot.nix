{
  ...
}:
{
  flake.nixosModules.grub-boot =
    {
      pkgs,
      lib,
      ...
    }:
    {
      boot.loader = {
        timeout = 2;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
        };
        efi = {
          canTouchEfiVariables = true;
        };
      };
    };
}
