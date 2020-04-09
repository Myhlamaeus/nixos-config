overlays: packageOverrides: { pkgs, lib, ... }:

let
  urxvtConfig = exts: with builtins; with lib;
    let
      mkPath = mods: strings.concatStringsSep ":" (map (mod: "${mod}/lib/urxvt/perl") mods);
      mkExts = strings.concatStringsSep ",";
      optElem = lib: ele: lists.optional (elem ele exts) lib;
      optElems = lib: eles: lists.optional (!(lists.mutuallyExclusive eles exts)) lib;

    in
      rec {
        "perl-lib" = with pkgs; mkPath
          (
            optElem urxvt_vtwheel "vtwheel"
            ++ optElem urxvt_autocomplete_all_the_things "autocomplete-ALL-the-things"
            ++ optElem urxvt_font_size "font-size"
            ++ optElems urxvt_perl [ "fullscreen" "newterm" ]
            ++ optElems urxvt_perls [ "clipboard" "keyboard-select" "url-select" ]
            ++ optElem urxvt_tabbedex "tabbedex"
            ++ optElem urxvt_theme_switch "theme-switch"
          );
        "perl-ext-common" = mkExts exts;
      };
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });


in
{
  imports = [
    ./browsers
    ./editors
    ./email.nix
    ./games
    ./git.nix
    ./x11.nix
    ./xmonad.nix
    ./direnv
  ];

  custom.games.enable = true;

  nixpkgs.overlays = overlays;
  nixpkgs.config = {
    allowUnfree = true;
    inherit packageOverrides;
  };
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowBroken = true;
      allowUnfree = true;
    }
  '';

  home.packages = (
    with pkgs; [
      # shell
      ag
      cheat
      jq
      python36Packages.powerline
      ranger
      nix-index
      # dev
      haskellPackages.stylish-haskell
      shellcheck
      ispell
      zeal
      sqlite
      # hs
      cabal-install
      cabal2nix
      hlint
      # term emulator
      rxvt_unicode
      # media
      mpc_cli
      mpv
      shutter
      greg
      # security
      gnupg
      keepassxc
      (pass.withExtensions (exts: with exts; [ pass-update pass-audit ]))
      keybase
      # other
      ledger
      weechat
      mysql-workbench
      # non-free
      discord
      # term emulator
      rxvt_unicode
      # media
      calibre
    ]
  )
  ++ (
        with pkgs-unstable; [
          zsh-completions
          niv
          (pkgs.add-optparse-applicative-completions { pkg = niv; bins = [ "niv" ]; })
          fahcontrol
          fahclient
          keybase-gui
          # media
          # because of plugin compatibility
          # calibre
        ]
      )
  ;
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/x-keepass2" = "org.keepassxc.KeePassXC.desktop";
    };
    defaultApplications = {
      "application/x-keepass2"  = "org.keepassxc.KeePassXC.desktop";
      "application/pdf"         = "chromium-browser.desktop";
      "x-scheme-handler/mailto" = "chromium-browser.desktop";
      "x-scheme-handler/webcal" = "chromium-browser.desktop";
    };
  };
  xdg.userDirs.enable = true;

  programs.browserpass.enable = true;

  services.keybase.enable = true;
  services.kbfs.enable = true;

  home.keyboard = {
    layout = "gb";
  };

  home.file.".editorconfig" = {
    source = builtins.toFile "editorconfig" ''
        ; EditorConfig helps developers define and maintain consistent
        ; coding styles between different editors and IDEs.

        ; For more visit http://editorconfig.org.
        root = true

        ; Choose between lf or rf on "end_of_line" property
        [*]
        indent_style = space
        end_of_line = lf
        charset = utf-8
        trim_trailing_whitespace = true
        insert_final_newline = true
        indent_size = 2

        [*.md]
        trim_trailing_whitespace = false
      '';
  };

  home.file.".curlrc" = {
    source = builtins.toFile "curlrc" ''
        # Disguise as IE 9 on Windows 7.
        user-agent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"

        # When following a redirect, automatically set the previous URL as referer.
        referer = ";auto"

        # Wait 60 seconds before timing out.
        connect-timeout = 60
      '';
  };

  services.gpg-agent = {
    enable = true;

    enableSshSupport = true;

    defaultCacheTtl = 600;
    defaultCacheTtlSsh = 600;
  };

  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    initExtra = ''
        setopt EXTENDED_GLOB NOMATCH HIST_REDUCE_BLANKS
        unsetopt autocd beep notify
        DEFAULT_USER=Myhlamaeus

        bindkey -v
        # https://unix.stackexchange.com/questions/438307/zsh-start-new-prompt-in-command-mode-vi-mode
        zle-line-init() { zle -K vicmd; }
        zle -N zle-line-init

        prompt_context(){}
      '';

    dotDir = ".config/zsh";

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };

  programs.urxvt = {
    enable = true;

    fonts = [ "xft:Roboto Mono Light for Powerline:size=10" ];

    extraConfig =
      (urxvtConfig [ "default" "clipboard" "keyboard-select" "tabbedex" "url-select" "vtwheel" ])
      // {
            "url-select.launcher" = "xdg-open";
            "url-select.underline" = "true";
          }
      ;

    keybindings = {
      "C-f" = "perl:keyboard-select:search";
      "C-Escape" = "perl:keyboard-select:activate";

      "M-u" = "perl:url-select:select_next";

      "Mod1-x" = "perl:clipboard:copy";
      "Mod1-y" = "perl:clipboard:paste";
    };
  };

  services.mpd = {
    enable = true;

    network = {
      listenAddress = "/home/Myhlamaeus/mpd.socket";
    };
  };


  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  home.file.".local/share/greg/data/data" = {
    text = ''
        [LifesLibrary]
        url = https://extras.lifeslibrarybookclub.com/feed.php?id=25fdd6f482baf1d8a5e22fb8746acce59215a059c7e05b4ee4ffe35726020592
        date_info = available

        [DearHankAndJohn]
        url = http://feeds.wnyc.org/dearhankandjohn
        date_info = available

        [TheAnthropoceneReviewed]
        url = http://feeds.wnyc.org/TheAnthropoceneReviewed
        date_info = available

        [SciShowTangents]
        url = http://feeds.wnyc.org/scishow-tangents
        date_info = available
      '';
  };
  home.file.".config/greg/greg.conf" = {
    source = ./greg.conf;
  };

  programs.command-not-found.enable = true;

  # services.bitlbee = {
  #   enable = true;
  #   plugins = [
  #     pkgs.bitlbee-discord
  #   ];
  # };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "18.09";
}
