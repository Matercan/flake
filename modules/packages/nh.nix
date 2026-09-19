{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    {
      packages.nh = (
        inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.nh;
          args = [
            "os"
            "switch"
            "."
            "-H"
            "hyprland-btw"
          ];
        }
      );
    };
}
