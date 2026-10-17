{ ... }:
{
  flake.nixosModules.nvidiaDrivers =
    {
      hostName,
      pkgs,
      ...
    }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      nixpkgs.config.allowUnfree = true;

      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

      boot.kernelParams = [ "nvidia-drm.modset=1" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = false;
        package = pkgs.linuxPackages_latest.nvidiaPackages.stable;

        powerManagement = {
          enable = true;
          finegrained = false;
        };

        prime =
          if hostName == "hyprland-btw" then
            {
              amdgpuBusId = "PCI:5:0:0";
              nvidiaBusId = "PCI:1:0:0";

              offload = {
                enable = true;
                enableOffloadCmd = true;
              };
            }
          else
            { };
      };
    };
}
