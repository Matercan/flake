{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      hostName = "server";
    };

    modules = with self.nixosModules; [
      serverConfiguration
      amdDrivers
      core
    ];
  };
}
