{ moduleWithSystem, ... }:
{
  flake.nixosModules.amdDrivers = {
    hardware.cpu.amd.updateMicrocode = moduleWithSystem (
      { lib, self' }: lib.mkDefault self'.hardware.enableRedistributableFirmware
    );
  };
}
