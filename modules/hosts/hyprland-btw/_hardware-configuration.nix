{
  # modulesPath,
  pkgs,
  ...
}:

{
  # imports = [
  #   (modulesPath + "/installer/scan/not-detected.nix")
  # ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "uinput"
  ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl."vm.unprivileged_userfaultfd" = 1;

  hardware.firmware = [ pkgs.linux-firmware ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8efff9a8-758d-4980-961f-4fada61b057b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FCB2-3CB2";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };
  boot.loader.efi.efiSysMountPoint = "/boot";
  bluetooth.enable = true;
  services.blueman.enable = true;

  swapDevices = [
    { device = "/dev/disk/by-uuid/652c383c-85c8-4378-8ead-b7a3bde23e04"; }
  ];
}
