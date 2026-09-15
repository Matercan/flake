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
      system = "x86_64-linux";
      inherit self;
    };

    modules = with self.nixosModules; [
      serverConfiguration
      amdDrivers
      core
    ];
  };
}
