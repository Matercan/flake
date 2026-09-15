{
  ...
}:
{
  flake.nixosModules.locale =
    {
      pkgs,
      lib,
      ...
    }:
    {
      time.timeZone = "Europe/Amsterdam";
      i18n = {
        defaultLocale = "en_US.UTF-8";
      };
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
      console.keyMap = "us";
    };
}
