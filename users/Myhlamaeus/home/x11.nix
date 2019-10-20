{ pkgs, ... }:

{
  home.packages = with pkgs; [ dmenu xclip ];

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
        ${pkgs.feh}/bin/feh --bg-scale ${./fedora_29_background-wallpaper-2560x1440.jpg}
      '';
    profileExtra = ''
        ${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse ~/media/google-drive
      '';
  };

  services.screen-locker = {
    enable = true;
    # Must be installed via configuration.nix and
    # referenced like this as it is wrapped
    lockCmd = "sh -c 'slock & sleep 0.5 && xset dpms force off'";
    xautolockExtraOptions = [ "-corners -000" ];
  };

  services.unclutter = {
    enable = true;
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.fira;
      name = "Fira Sans 8";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.adapta-gtk-theme;
      name = "Adapta-Nokto";
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  xresources = {
    extraConfig = builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "logico-dev";
        repo = "Xresources-themes";
        rev = "1df25bf5b2e639e8695e8f2eb39e9d373af3b888";
        sha256 = "0jjnnkyps2v0qdylad9ci2izpn0zqlkpdlv626sbhw35ayghxpv4";
      }
      + "/base16-spacemacs-256.Xresources"
    );
  };
}
