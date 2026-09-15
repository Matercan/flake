{ ... }:
{
  flake.nixosModules.serverConfiguration =
    { ... }:
    {
      networking = {
        hostName = "server";
        nameservers = [
          "8.8.8.8"
          "1.1.1.1"
        ];
      };
      imports = [ ./_hardware-configuration.nix ];
    };
}
