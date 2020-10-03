{ config, lib, pkgs, modulesPath, ... }:

with lib;

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Some recent nixpkgs-unstable change broke hardware.deviceTree.base
  # hardware.opengl = {
  #   enable = true;
  #   setLdLibraryPath = true;
  #   package = pkgs.mesa_drivers;
  # };
  # hardware.deviceTree = {
  #   base = pkgs.device-tree_rpi;
  #   overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  # };
  # boot.loader.raspberryPi.firmwareConfig = ''
  #   gpu_mem=192
  # '';
}
