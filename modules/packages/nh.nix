{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      lib,
      hostName,
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
            hostName
          ];
        }
      );
    };
}
