# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  bitlbeeDiscord = with pkgs; with stdenv.lib;
    stdenv.mkDerivation rec {
      name = "bitlbee-discord-2017-12-27";

      src = fetchFromGitHub {
        rev = "aa0bbf2df851b1fd1b27164713121d20c610b7c5";
        owner = "sm00th";
        repo = "bitlbee-discord";
        sha256 = "02pigk2vbz0jdz11f96sygdvp1j762yjn62h124fkcsc070g7a2f";
      };

      nativeBuildInputs = [ autoreconfHook pkgconfig ];
      buildInputs = [ bitlbee glib ];

      preConfigure = ''
        export BITLBEE_PLUGINDIR=$out/lib/bitlbee
        ./autogen.sh
      '';

      meta = {
        description = "Bitlbee plugin for Discord";

        homepage = https://github.com/sm00th/bitlbee-discord;
        license = licenses.gpl2Plus;
        maintainers = [ maintainers.lassulus ];
        platforms = stdenv.lib.platforms.linux;
      };
    };
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
    url = "https://github.com/nix-community/NUR/archive/44626b757f6d3fd8c87239953d3d670e75bab3b8.tar.gz";
    # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
    sha256 = "1gfgl7qimp76q4z0nv55vv57yfs4kscdr329np701k0xnhncwvrk";
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ./users/Myhlamaeus/home
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
    # consoleKeyMap = "gb";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "UTC";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # shell
    wget neovim git ncurses
    # vm
    nixops
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  programs.slock.enable = true;

  # List font packages
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira
      fira-code
      fira-code-symbols
      mplus-outline-fonts
      dina-font
      proggyfonts
      iosevka
      fixedsys-excelsior
      powerline-fonts
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Fira Code" ];
        sansSerif = [ "Fira Sans" ];
      };
      ultimate.enable = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.zsh.enableCompletion = true;
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    layout = "gb";
    # xkbVariant = "intl";
    # xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput.enable = true;

    displayManager.lightdm.enable = true;

    windowManager.xmonad.enable = true;
    windowManager.default = "xmonad";
  };

  # Needed for home-manager GTK themes
  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # Video drivers
  boot.extraModprobeConfig = "options nvidia-drm modeset=1";
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;

  hardware.u2f.enable = true;

  # Temporarily, until supported by home-manager.
  services.bitlbee = {
    enable = true;
    plugins = [
      bitlbeeDiscord
    ];
  };

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  virtualisation.libvirtd.enable = true;

  nix.nixPath = [
    (let
      sshConfigFile =
        pkgs.writeText "ssh_config" ''
          Host github.com
          IdentityFile /etc/ssh/ssh_host_rsa_key
          StrictHostKeyChecking=no
        '';
    in
      "ssh-config-file=${sshConfigFile}"
    )
    # The following lines are just the default values of NIX_PATH
    # We have to keep them to not brick the system
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
