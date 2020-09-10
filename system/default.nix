# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  sources = import ../nix/sources.nix;
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  imports =
    [
      <nixpkgs/nixos/modules/profiles/hardened.nix>
      ./cachix.nix
      (sources.home-manager + "/nixos")
      ../users
    ];

  # <nixpkgs>'s hardened kernel doesn't support 32 bit emulation (`linuxPackages_hardened.kernel.features.ia32Emulation`)
  # The hardened kernel breaks Chromium
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelModules = [ "usb_storage" "fuse" ];
  # Required for `nix.useSandbox`
  security.allowUserNamespaces = true;

  boot.tmpOnTmpfs = true;

  nixpkgs.overlays = [
    (self: super: {
      add-optparse-applicative-completions = { pkg, bins }: super.pkgs.symlinkJoin {
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
      omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
          version = sources.omnisharp-roslyn.version;
          src = sources.omnisharp-roslyn;
        });
    })
    (self: super: {
      chromium = super.chromium.override {
          commandLineArgs = "--force-dark-mode";
          enableWideVine = true;
          enableVaapi = true;
        };
    })
    (self: super: {
      teensy-loader-cli = super.teensy-loader-cli.overrideAttrs (attrs: rec {
          postInstall = (attrs.postInstall or "") + ''
            mkdir -p $out/lib/udev/rules.d
            cp ${sources.teensy-udev-rules} $out/lib/udev/rules.d/49-teensy.rules
          '';
        });
    })
    (self: super: {
      cheatPackages = {
        community = sources.cheatsheets;
      };
    })
    (self: super: {
      pass-git-helper = super.python38Packages.buildPythonApplication {
        pname = "pass-git-helper";
        version = sources.pass-git-helper.branch;
        versionSuffix = "-git";

        propagatedBuildInputs = with pkgs.python38Packages; [ pyxdg ];
        checkInputs = with pkgs.python38Packages; [ coveralls pytest pytest-mock ];

        src = sources.pass-git-helper;

        doCheck = false;
      };
    })
    (self: super: {
      inherit (pkgs-unstable) openmw dwarf-fortress-packages;
    })
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import sources.nur {
      inherit pkgs;
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  hardware.enableAllFirmware = true;

  services.atd.enable = true;

  services.udev.packages = with pkgs; [ teensy-loader-cli steamPackages.steam ];
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
    (add-optparse-applicative-completions { pkg = cachix; bins = [ "cachix" ]; })
    # shell
    wget
    neovim
    git
    ncurses
    # vm
    nixops
  ];

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
      cm_unicode
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "CMU Sans Serif" "Noto Color Emoji" ];
        sansSerif = [ "CMU Sans Serif" "Noto Color Emoji" ];
        serif = [ "CMU Serif" "Noto Color Emoji" ];
      };
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint ];
  hardware.sane.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

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

  hardware.u2f.enable = true;

  services.smartd = {
    enable = true;

    notifications.x11.enable = true;
  };

  # Temporarily, until supported by home-manager.
  services.bitlbee = {
    enable = true;
    plugins = with pkgs; [
      bitlbee-discord
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.anbox.enable = true;
  programs.adb.enable = true;

  services.davfs2.enable = true;
  fileSystems."/home/Myhlamaeus/webdav" = {
    device = "https://webdav.maurice-dreyer.name";
    fsType = "davfs";
    options = [ "_netdev" "user" "uid=Myhlamaeus" "gid=users" ];
  };
  users.users.Myhlamaeus.extraGroups = [ config.services.davfs2.davGroup ];

  nix.nixPath = [
    (
      let
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

  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 5d";
  };
  nix.optimise = {
    automatic = true;
    dates = ["05:30"];
  };
  system.autoUpgrade = {
    enable = true;
    dates = "04:30";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}