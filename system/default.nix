# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./cachix.nix ./audio.nix ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # <nixpkgs>'s hardened kernel doesn't support 32 bit emulation (`linuxPackages_hardened.kernel.features.ia32Emulation`)
  # The hardened kernel breaks Chromium
  boot.kernelPackages = pkgs.linuxPackages;
  boot.extraModulePackages = with pkgs; [ akvcam linuxPackages.v4l2loopback ];
  boot.kernelModules =
    [ "usb_storage" "fuse" "v4l2loopback" "videodev" "akvcam" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1  exclusive_caps=1 video_nr=2 card_label="v4l2loopback"
  '';
  security.lockKernelModules = false;
  # Required for `nix.useSandbox`
  security.allowUserNamespaces = true;

  boot.tmpOnTmpfs = true;

  boot.loader.grub.memtest86.enable = true;

  nixpkgs.overlays = [
    (self: super: {
      add-optparse-applicative-completions = { pkg, bins }:
        super.pkgs.symlinkJoin {
          name = "${pkg.name}-with-completion";
          paths = [ pkg ];
          buildInputs = [ super.pkgs.coreutils ];
          postBuild = ''
            mkdir -p $out/share/{bash-completion/completions,zsh/site-functions,fish/completions}
            ${super.lib.concatMapStringsSep "\n" (n: ''
              $out/bin/${n} --bash-completion-script=$out/bin/${n} >$out/share/bash-completion/completions/${n}
              $out/bin/${n} --zsh-completion-script=$out/bin/${n} >$out/share/zsh/site-functions/_${n}
              $out/bin/${n} --fish-completion-script=$out/bin/${n} >$out/share/fish/completions/_${n}
            '') bins}
          '';
        };
    })
    (self: super: {
      chromium = super.chromium.override {
        commandLineArgs =
          "--force-dark-mode --enable-features=VaapiVideoDecoder";
        enableWideVine = true;
      };
    })
    (self: super: {
      steam = super.steam.override {
        extraPkgs = pkgs: with pkgs; [ pipewire.lib ];
        extraLibraries = pkgs:
          with pkgs;
          with config.hardware.opengl;
          if self.hostPlatform.is64bit then
            [ pipewire.lib package ] ++ extraPackages
          else
            [ pipewire.lib package32 ] ++ extraPackages32;
      };
    })
  ];

  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  programs.steam.enable = true;

  hardware.enableAllFirmware = true;

  services.atd.enable = true;

  services.udev.packages = with pkgs; [
    teensy-loader-cli
    steamPackages.steam
    openhantek6022
    libsigrok
  ];
  # options.hardware.steam-hardware.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
      LC_MONETARY = "en_IE.UTF-8";
    };
  };
  console = {
    useXkbConfig = true;
    font = "Lat2-Terminus16";
  };

  # Set your time zone.
  time.timeZone = "UTC";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # nix
    cachix
    nixopsUnstable
    # shell
    wget
    neovim
    git
    ncurses
    # vm
    nixops
    gparted
  ];

  programs.slock.enable = true;

  # List font packages
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-emoji-blob-bin
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
      cm_unicode
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Fira Code" "emoji" ];
        sansSerif = [ "CMU Sans Serif" "Noto Sans" "emoji" ];
        serif = [ "CMU Serif" "Noto Serif" "emoji" ];
        emoji = [ "Blobmoji" "Noto Color Emoji" ];
      };

      overrides = [
        {
          sources =
            [ "Arial" "Helvetica" "Helvetica Neue" "Roboto" "Segoe UI" ];
          targets = [ "serif" "sans-serif" ];
        }
        {
          sources = [ "Consolas" "Inconsolata" ];
          targets = [ "monospace" ];
        }
      ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 51413 ];
  networking.firewall.allowedUDPPorts = [ 51413 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 1714;
    to = 1764;
  }];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint ];
  # hardware.sane.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    layout = "gb";
    # xkbVariant = "intl";
    # xkbOptions = "eurosign:e";

    # Enable touchpad support.
    libinput.enable = true;
    digimend.enable = true;

    displayManager.lightdm.enable = true;

    windowManager.xmonad.enable = true;
    displayManager.defaultSession = "none+xmonad";
  };

  services.fwupd.enable = true;

  # Needed for home-manager GTK themes
  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # Video drivers
  hardware.opengl.driSupport32Bit = true;

  services.smartd = {
    enable = true;

    notifications.x11.enable = true;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  # virtualisation.anbox.enable = true;
  programs.adb.enable = true;

  services.davfs2.enable = true;
  fileSystems."/home/Myhlamaeus/webdav" = {
    device = "https://webdav.maurice-dreyer.name";
    fsType = "davfs";
    options = [ "_netdev" "user" "uid=Myhlamaeus" "gid=users" ];
  };
  users.users.Myhlamaeus.extraGroups = [ config.services.davfs2.davGroup ];

  services.foldingathome = {
    enable = true;
    user = "Myhlamaeus";
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs;
      let
        mopidy-funkwhale = callPackage
          ({ lib, fetchurl, python3Packages, mopidy }:

            python3Packages.buildPythonApplication rec {
              pname = "mopidy-funkwhale";
              version = "master-git";

              src = fetchurl {
                url =
                  "https://dev.funkwhale.audio/funkwhale/mopidy/-/archive/master/mopidy-master.tar.gz";
                sha256 = "LUzv7wijHgLB3QY0OifJ6TZ3VajvLv2cRg7s0bFsmx4=";
              };

              propagatedBuildInputs = [ mopidy ] ++ (with python3Packages; [
                requests
                requests_oauthlib
                pygobject3
              ]);

              patches = [ ./mopidy-funkwhale.patch ];

              doCheck = false;

              meta = with lib; {
                homepage = "https://www.mopidy.com/";
                description =
                  "Mopidy extension for playing music from Funkwhale";
                license = licenses.gpl3;
                maintainers = [ ];
                hydraPlatforms = [ ];
              };
            }) { };
      in [ mopidy-mpd mopidy-funkwhale ];
    configuration = builtins.readFile
      ((pkgs.formats.ini { }).generate "mopidy-config" {
        funkwhale = {
          enabled = true;
          url = "https://funkwhale.maurice-dreyer.name";
          client_id = "Byxrpf6Ryx226JXyym0sNeJ0CnDi21kP8KRdv6qT";
          client_secret = "25swnWHkptPy8VP7XDl4oVMjrNdOd0";
        };
      });
  };

  nix.nixPath = [
    (let
      sshConfigFile = pkgs.writeText "ssh_config" ''
        Host github.com
        IdentityFile /etc/ssh/ssh_host_rsa_key
        StrictHostKeyChecking=no
      '';
    in "ssh-config-file=${sshConfigFile}")
    # The following lines are just the default values of NIX_PATH
    # We have to keep them to not brick the system
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 5d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "05:30" ];
  };
  system.autoUpgrade = {
    enable = false;
    dates = "04:30";
  };

  services.gnome.at-spi2-core.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?
}
