{ config, pkgs, lib, ... }:

with lib;
let cfg = config.custom.x11;

in {
  options.custom.x11 = { enable = mkEnableOption "x11"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ xclip (dunst.override { dunstify = true; }) ];

    services.redshift = {
      enable = true;
      latitude = "53.2626212";
      longitude = "10.4411094";
      brightness = {
        day = "0.9";
        night = "0.3";
      };
      temperature = {
        day = 5500;
        night = 2000;
      };
    };

    xsession = {
      enable = true;
      initExtra = ''
        # http://wallpaperswide.com/fedora_29_background-wallpapers.html
        ${pkgs.feh}/bin/feh --bg-scale ${
          ./fedora_29_background-wallpaper-2560x1440.jpg
        }
      '';
      profileExtra = ''
        ${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse ~/media/google-drive
      '';
    };

    services.screen-locker = {
      enable = true;
      # slock must be installed via configuration.nix and
      # referenced like this as it is wrapped
      lockCmd = let
        cmd = pkgs.writeScript "lock" ''
          ${pkgs.libnotify}/bin/notify-send DUNST_COMMAND_PAUSE
          /run/wrappers/bin/slock
          ${pkgs.libnotify}/bin/notify-send DUNST_COMMAND_RESUME
        '';
      in "${pkgs.bash}/bin/bash -c '${cmd} & ${pkgs.coreutils}/bin/sleep 0.5 && ${pkgs.xlibs.xset}/bin/xset dpms force off'";
      # lockCmd = "${pkgs.bash}/bin/bash -c '${pkgs.libnotify}/bin/notify-send DUNST_COMMAND_PAUSE; /run/wrappers/bin/slock ${pkgs.libnotify}/bin/notify-send DUNST_COMMAND_RESUME & ${pkgs.coreutils}/bin/sleep 0.5 && ${pkgs.xlibs.xset}/bin/xset dpms force off'";
      xautolockExtraOptions = [ "-corners -000" ];
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "1000x1+0+0";
          shrink = true;
          frame_color = "#eceff1";
          font = "Fira Code 8";
          word_wrap = true;
          stack_duplicates = true;
          browser = "firefox";
          dmenu = "${pkgs.dmenu}/bin/dmenu";
        };

        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };
      };
    };

    services.unclutter = { enable = true; };

    gtk = {
      enable = true;
      font = {
        package = pkgs.cm_unicode;
        name = "CMU Sans Serif 8";
      };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
      theme = {
        package = pkgs.adapta-gtk-theme;
        name = "Adapta-Nokto";
      };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    programs.rofi = {
      enable = true;
      theme = "android_notification";
      extraConfig = ''
        rofi.kb-remove-char-back:  BackSpace
        rofi.kb-accept-entry:  Return,KP_Enter
        rofi.kb-remove-to-eol:  Shift+BackSpace
        rofi.kb-move-char-back:  Left
        rofi.kb-move-char-forward:  Right
        rofi.kb-row-left:          Control+h
        rofi.kb-row-right:         Control+l
        rofi.kb-row-down:          Control+j
        rofi.kb-row-up:            Control+k
        rofi.kb-page-prev:         Control+b
        rofi.kb-page-next:         Control+f
      '';
    };

    xresources = {
      extraConfig = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "logico-dev";
        repo = "Xresources-themes";
        rev = "1df25bf5b2e639e8695e8f2eb39e9d373af3b888";
        sha256 = "0jjnnkyps2v0qdylad9ci2izpn0zqlkpdlv626sbhw35ayghxpv4";
      } + "/base16-spacemacs-256.Xresources");
    };
  };
}
