{
  ...
}:
{
  flake.nixosModules.systemd-boot =
    {
      pkgs,
      lib,
      ...
    }:
    {
      boot.loader = {
        timeout = 2;
        efi = {
          canTouchEfiVariables = true;
        };
        systemd-boot.enable = true;
      };
    };
}
