{ config, lib, pkgs, ... }:

{
  # anbox
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;

  # encrypted boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
    };
  };
  boot.supportedFilesystems = [ "btrfs" ];

  # Video drivers
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option "metamodes" "2560x1440_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    '';
  };
  hardware.opengl = {
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  };
  virtualisation.docker.enableNvidia = true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "uas" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."system".device =
    "/dev/disk/by-uuid/7da04a18-1528-40a2-b9b3-4e9c72b4a68c";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=log" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/home/Myhlamaeus/.ghq" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=code" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home/Myhlamaeus/media/games" = {
    device = "/dev/disk/by-uuid/a6cd8e9f-9dd9-4d3a-a9df-50de260a09a9";
    fsType = "ext4";
  };

  fileSystems."/home/Myhlamaeus/Maildir" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=email" "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home/Myhlamaeus/Calibre Library" = {
    device = "/dev/disk/by-uuid/31c80009-953a-4864-8b01-1796ea6f5848";
    fsType = "btrfs";
    options = [ "subvol=ebooks" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ee27b505-9ebb-402d-9d61-4d40faad069d";
    fsType = "ext2";
  };

  boot.initrd.luks.devices."boot".device =
    "/dev/disk/by-uuid/b195292e-4542-4c0a-ac27-1d2d74887fea";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/1550-D577";
    fsType = "vfat";
  };

  boot.initrd.luks.devices."swap".device =
    "/dev/disk/by-uuid/bf64a226-8eb1-45eb-a2f8-d21fc5b4f68d";

  swapDevices = [{ device = "/dev/mapper/swap"; }];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font =
    lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };
}
