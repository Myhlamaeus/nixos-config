{ config, pkgs, lib, ... }:

let
  urxvtConfig = exts:
    with builtins;
    with lib;
    let
      mkPath = mods:
        strings.concatStringsSep ":" (map (mod: "${mod}/lib/urxvt/perl") mods);
      mkExts = strings.concatStringsSep ",";
      optElem = lib: ele: lists.optional (elem ele exts) lib;
      optElems = lib: eles:
        lists.optional (!(lists.mutuallyExclusive eles exts)) lib;

    in rec {
      "perl-lib" = with pkgs;
        mkPath (optElem urxvt_vtwheel "vtwheel"
          ++ optElem urxvt_autocomplete_all_the_things
          "autocomplete-ALL-the-things" ++ optElem urxvt_font_size "font-size"
          ++ optElems urxvt_perl [ "fullscreen" "newterm" ]
          ++ optElems urxvt_perls [ "clipboard" "keyboard-select" "url-select" ]
          ++ optElem urxvt_tabbedex "tabbedex"
          ++ optElem urxvt_theme_switch "theme-switch");
      "perl-ext-common" = mkExts exts;
    };

in {
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
  custom.x11.enable = true;

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowBroken = true;
      allowUnfree = true;
    }
  '';

  home.packages = (with pkgs; [
    # shell
    ag
    # cheat
    jq
    python3Packages.powerline
    ranger
    nix-index
    zsh-completions
    # dev
    obelisk
    openhantek6022
    pulseview
    shellcheck
    sqlite
    zeal
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
    # security
    gnupg
    (pass.withExtensions (exts: with exts; [ pass-update pass-audit ]))
    # graphics
    alchemy
    blender
    gimp
    inkscape
    krita
    # social
    (element-desktop.override {
      element-web =
        element-web.override { conf = { showLabsSettings = true; }; };
    })
    hydroxide
    keybase
    protonmail-bridge
    # other
    fahcontrol
    fahviewer
    ledger
    transmission-gtk
    vlc
    # non-free
    discord
    (p7zip.override { enableUnfree = true; })
    # term emulator
    rxvt_unicode
    # media
    calibre
    # aspell
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.la
    orca
  ]);
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/epub+zip" = "emacs.desktop";
      "application/pdf" = "emacs.desktop";
      "application/rss+xml" = "emacs.desktop";
      "x-scheme-handler/magnet" = "userapp-transmission-gtk-IMV9S0.desktop";
    };
    defaultApplications = {
      "application/epub+zip" = "emacs.desktop";
      "application/pdf" = "emacs.desktop";
      "application/rss+xml" = "emacs.desktop";
      "x-scheme-handler/magnet" = "userapp-transmission-gtk-IMV9S0.desktop";
    };
  };
  xdg.userDirs.enable = true;

  home.activation.home-dir-permissions =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD find ~ \
        -path "$HOME/media" -prune -o \
        -path "$HOME/webdav" -prune -o \
        -type d \
        -exec setfacl -dm "o::000" "{}" + \
        -exec setfacl -dm "g::000" "{}" + \
        -exec chmod go-rwx "{}" +
      $DRY_RUN_CMD find ~ \
        -path "$HOME/media" -prune -o \
        -path "$HOME/webdav/lost+found" -prune -o \
        -path "$HOME/webdav/mnt/lost+found" -prune -o \
        -type f \
        -exec chmod go-rwx "{}" +
    '';

  programs.browserpass.enable = true;

  services.keybase.enable = true;
  services.kbfs = {
    enable = true;
    mountPoint = "media/keybase";
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

    extraConfig = (urxvtConfig [
      "default"
      "clipboard"
      "keyboard-select"
      "tabbedex"
      "url-select"
      "vtwheel"
    ]) // {
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

  programs.bat = {
    enable = true;
    config = { theme = "TwoDark"; };
  };

  home.file.".ledgerrc".text = let
    formatPair = k: v: if v == true then "--${k}" else "--${k}=${toString v}";
    toConfig = cfg:
      with lib;
      with builtins;
      concatStringsSep "\n" (map (concatStringsSep "\n") (mapAttrsToList (k: v:
        if typeOf v == "list" then
          map (formatPair k) v
        else
          [ (formatPair k v) ]) cfg));

  in toConfig {
    input-date-format = "%F";
    date-format = "%F";
    datetime-format = "%FT%T";
    strict = true;
  };

  xdg.configFile."cheat/conf.yml".text = builtins.toJSON {
    # The editor to use with 'cheat -e <sheet>'. Defaults to $EDITOR or $VISUAL.
    # editor = pkgs.neovim + "/bin/nvim";

    # Should 'cheat' always colorize output?
    colorize = true;

    # Which 'chroma' colorscheme should be applied to the output?
    # Options are available here:
    #   https://github.com/alecthomas/chroma/tree/master/styles
    style = "emacs";

    # Which 'chroma' "formatter" should be applied?
    # One of: "terminal", "terminal256", "terminal16m"
    formatter = "terminal16m";

    # The paths at which cheatsheets are available. Tags associated with a cheatpath
    # are automatically attached to all cheatsheets residing on that path.
    #
    # Whenever cheatsheets share the same title (like 'tar'), the most local
    # cheatsheets (those which come later in this file) take precedent over the
    # less local sheets. This allows you to create your own "overides" for
    # "upstream" cheatsheets.
    #
    # But what if you want to view the "upstream" cheatsheets instead of your own?
    # Cheatsheets may be filtered via 'cheat -f <tag>' in combination with other
    # commands. So, if you want to view the 'tar' cheatsheet that is tagged as
    # 'community' rather than your own, you can use: cheat tar -f community
    cheatpaths = [
      # Paths that come earlier are considered to be the most "global", and will
      # thus be overridden by more local cheatsheets. That being the case, you
      # should probably list community cheatsheets first.
      #
      # Note that the paths and tags listed below are just examples. You may freely
      # change them to suit your needs.
      {
        name = "community";
        path = pkgs.cheatPackages.community;
        tags = [ "community" ];
        readonly = true;
      }

      # Maybe your company or department maintains a repository of cheatsheets as
      # well. It's probably sensible to list those second.
      # {
      #   name = "work";
      #   path = work;
      #   tags = [ "work" ];
      #   readonly = true;
      # }

      # If you have personalized cheatsheets, list them last. They will take
      # precedence over the more global cheatsheets.
      # {
      #   name = "personal";
      #   path = personal;
      #   tags = [ "personal" ];
      #   readonly = true;
      # }
    ];
  };

  programs.command-not-found.enable = true;

  services.kdeconnect.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "20.03";
}
