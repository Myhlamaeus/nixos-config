{ pkgs, lib, ... }:

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
    imports = [
      ./browsers/chromium.nix ./browsers/firefox.nix ./editors/emacs.nix ./editors/neovim.nix
      ./email.nix ./git.nix ./x11.nix ./xmonad.nix
    ];

    home.packages = with pkgs; [
      # shell
      jq python36Packages.powerline ranger
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
      calibre mpc_cli mpv shutter greg
      # security
      gnupg keepassxc pass
      # other
      hledger weechat mysql-workbench
      # non-free
      discord steam
      # term emulator
      rxvt_unicode
    ];

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
        bindkey -v
        DEFAULT_USER=Myhlamaeus
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

      network = {
        listenAddress = "/run/mpd/socket";
      };
    };

    programs.newsboat = {
      enable = true;
      autoReload = true;
      urls = [
        { tags = [ "anime" ];      url = "http://www8.watch-anime.org/feed/"; }
        { tags = [ "lightnovel" ]; url = "https://www.wuxiaworld.com/feed/chapters"; }
        { tags = [ "manga" ];      url = "https://readms.net/rss"; }
        { tags = [ ];              url = "https://xkcd.com/atom.xml"; }
        { tags = [ "programming" "haskell" ]; url = "https://haskellweekly.news/haskell-weekly.atom"; }
      ];
      extraConfig = ''
        color background          white   black
        color listnormal          white   black
        color listfocus           white   blue   bold
        color listnormal_unread   magenta black
        color listfocus_unread    magenta blue   bold
        color info                white   blue   bold
        color article             white   black
      '';
    };

    home.file.".local/share/greg/data/data" = {
      source = builtins.toFile "data" ''
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
