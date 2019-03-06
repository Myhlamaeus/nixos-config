{ config, pkgs, lib, callPackage, ... }:

let
  unstable = import <nixpkgs-unstable> {};

  urxvtConfig = exts: with builtins; with lib;
    let
      mkPath = mods: strings.concatStringsSep ":" (map (mod: "${mod}/lib/urxvt/perl") mods);
      mkExts = strings.concatStringsSep ",";
      optElem = lib: ele: lists.optional (elem ele exts) lib;
      optElems = lib: eles: lists.optional (!(lists.mutuallyExclusive eles exts)) lib;

    in
      rec {
        "perl-lib" = with pkgs; mkPath
          (  optElem  urxvt_vtwheel "vtwheel"
          ++ optElem  urxvt_autocomplete_all_the_things "autocomplete-ALL-the-things"
          ++ optElem  urxvt_font_size "font-size"
          ++ optElems urxvt_perl ["fullscreen" "newterm"]
          ++ optElems urxvt_perls ["clipboard" "keyboard-select" "url-select"]
          ++ optElem  urxvt_tabbedex "tabbedex"
          ++ optElem  urxvt_theme_switch "theme-switch"
          );
        "perl-ext-common" = mkExts exts;
      };

in
  {
    imports = [ ./xmonad.nix ];

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      # shell
      jq python36Packages.powerline ranger zsh
      # dev
      haskellPackages.stylish-haskell shellcheck
      # git
      gitAndTools.git-open gitAndTools.git-recent
      # x11
      dmenu xclip
      # hs
      cabal-install cabal2nix hlint
      # term emulator
      rxvt_unicode
      # media
      calibre mpc_cli mpv shutter
      # security
      gnupg keepassxc pass
      # (pass.withExtensions (exts: with exts; [ pass-import ]))
      # other
      hledger weechat mysql-workbench tor-browser-bundle
      # non-free
      unstable.pkgs.discord google-chrome steam
    ];

    home.keyboard = {
      layout = "gb";
    };

    home.sessionVariables = {
      EDITOR = "emacs";
      BROWSER = "google-chrome-stable";
    };

    home.stateVersion = "18.09";

    accounts.email.accounts = {
      home = {
        primary = true;
        flavor = "gmail.com";
        address = "dreyer.maltem@gmail.com";
        userName = "dreyer.maltem@gmail.com";
        realName = "Malte-Maurice Dreyer";
        notmuch.enable = true;
        mbsync = {
          enable = true;
          create = "both";
          patterns = [
            "*" "![Gmail]*" "[Gmail]/Sent Mail"
            "[Gmail]/Starred" "[Gmail]/All Mail"
          ];
        };
        msmtp = {
          enable = true;
        };
        passwordCommand = "${pkgs.pass}/bin/pass show 'Private Passwords/Email/Google'";
      };
    };
    programs.alot = {
      enable = true;
    };
    programs.notmuch = {
      enable = true;
      maildir.synchronizeFlags = true;
    };
    programs.mbsync.enable = true;
    services.mbsync = {
      enable = true;
      postExec = "NOTMUCH_CONFIG=~/.config/notmuch/notmuchrc ${pkgs.notmuch}/bin/notmuch new";
    };
    programs.msmtp.enable = true;

    programs.neovim = {
      enable = true;

      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          # loaded on launch
          start = [ vim-nix ];
          # manually loadable by calling `:packadd $plugin-name`
          opt = [ ];
        };
      };
    };

    programs.emacs = {
      enable = true;

      extraPackages = epkgs: with epkgs; [
        # undo-tree
        # evil
        # evil-leader
        # evil-anzu
        # evil-args
        # evil-ediff
        # evil-exchange
        # evil-iedit-state
        # evil-indent-plus
        # evil-lisp-state
        # evil-mc
        # evil-nerd-commenter
        # evil-matchit
        # evil-numbers
        # evil-search-highlight-persist
        # evil-surround
        # # ;; Temporarily disabled, pending the resolution of
        # # ;; https://github.com/7696122/evil-terminal-cursor-changer/issues/8
        # # ;; evil-terminal-cursor-changer
        # # evil-tutor
        # # (evil-unimpaired :location (recipe :fetcher local))
        # evil-visual-mark-mode
        # # (hs-minor-mode :location built-in)
        # linum-relative
        # vi-tilde-fringe
        # org-plus-contrib

        # expand-region
        # iedit
        # haskell-mode
      ];
    };

    programs.firefox = {
      enable = true;
    };

    programs.git = import ./git.nix { inherit pkgs; };

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
        setopt extendedglob nomatch
        unsetopt autocd beep notify
        bindkey -v
        DEFAULT_USER=Myhlamaeus
        prompt_context(){}
      '';

      history = {
        extended = true;
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
        (urxvtConfig ["default" "clipboard" "keyboard-select" "tabbedex" "url-select" "vtwheel"])
        // {
          "url-select.launcher" = "xdg-open";
          "url-select.underline" = "true";
        };

      keybindings = {
        "C-f" = "perl:keyboard-select:search";
        "C-Escape" = "perl:keyboard-select:activate";

        "M-u" = "perl:url-select:select_next";

        "Mod1-x" = "perl:clipboard:copy";
        "Mod1-y" = "perl:clipboard:paste";
      };
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    services.mpd = {
      enable = true;
    };

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

    # services.bitlbee = {
    #   enable = true;
    #   plugins = [
    #     pkgs.bitlbee-discord
    #   ];
    # };

    xsession = {
      enable = true;
      initExtra = ''
        # http://wallpaperswide.com/fedora_29_background-wallpapers.html
        ${pkgs.feh}/bin/feh --bg-scale ~/images/fedora_29_background-wallpaper-2560x1440.jpg
      '';
      profileExtra = ''
        ${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse ~/google-drive
        ${pkgs.xdg_utils}/bin/xdg-settings set default-web-browser google-chrome.desktop
      '';
    };

    services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.slock}/bin/slock";
    };

    services.unclutter = {
      enable = true;
    };

    xresources = {
      extraConfig = builtins.readFile (
        pkgs.fetchFromGitHub {
          owner = "logico-dev";
          repo = "Xresources-themes";
          rev = "1df25bf5b2e639e8695e8f2eb39e9d373af3b888";
          sha256 = "0jjnnkyps2v0qdylad9ci2izpn0zqlkpdlv626sbhw35ayghxpv4";
        } + "/base16-spacemacs-256.Xresources"
      );
    };
  }
