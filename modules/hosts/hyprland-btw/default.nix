{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.hyprland-btw = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      system = "x86_64-linux";
      hostName = "hyprland-btw";
      inherit self;
    };

    modules = with self.nixosModules; [
      inputs.hjem.nixosModules.default 
      hyprlandConfiguration
      amdDrivers
      nvidiaDrivers
      core
    ];
  };

}
