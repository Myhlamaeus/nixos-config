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

  # Video drivers
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option "metamodes" "2560x1440_144 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    '';
  };
  hardware.opengl = {
    extraPackages = with pkgs; [
      libvdpau-va-gl
      vaapiVdpau
    ];
  };
  nixpkgs.overlays = [
    (self: super: {
      chromium = super.chromium.override {
        enableVaapi = true;
      };
    })
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "uas" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."encrypted-boot" = {
    device = "/dev/disk/by-uuid/4f5491cf-feb1-45c8-8bf4-a9d4f19c8103";
    preLVM = true;
  };

  boot.initrd.luks.devices."encrypted-lvm" = {
    device = "/dev/disk/by-uuid/3406eeb7-00da-4ecb-ac08-f2f5d6cdd049";
    preLVM = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d09b6a47-adc0-460b-9736-bfcf18a5772d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5ee265fc-0320-4acc-b69e-1af90955136b";
      fsType = "ext2";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/31F5-7439";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/155b4f53-416b-4fb3-a87e-465fdb65453a";
      fsType = "ext4";
    };

  fileSystems."/home/Myhlamaeus/media/games" =
    { device = "/dev/disk/by-partlabel/games";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/23aae00f-4f92-4f37-9bd0-e652251f8b33"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
