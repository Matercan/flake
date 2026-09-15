{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.hyprland-btw = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      hostName = "hyprland-btw";
      inherit self;
    };

    modules = with self.nixosModules; [
      hyprlandConfiguration
      amdDrivers
      nvidiaDrivers
      core
    ];
  };

}
