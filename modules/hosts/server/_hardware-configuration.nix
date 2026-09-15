{
  ...
}:
{
  fileSystems = {
    "/" = {
      device = "";
      fsType = "ex4";
    };

    "/boot" = {
      device = "";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  boot.loader.efi.efiSysMountPoint = "/boot";
}
