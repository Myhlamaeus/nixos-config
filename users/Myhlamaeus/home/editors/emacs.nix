{ config, lib, pkgs, ... }:

with lib;
let cfg = config.custom.editors;

in {
  options.custom.editors.emacs = {
    setup = mkOption { type = with types; lines; };

    spacemacs = {
      ref = mkOption {
        type = with types; str;
        default = "develop";
      };
      rev = mkOption {
        type = with types; str;
        default = "40ae5e2293c6edb5aed1c554ec6b825f24db45d8";
      };
    };
  };

  config = {
    custom.editors.env.bin.packages = with pkgs; [
      gnuplot
      unzip
      texlive.combined.scheme-full
      python3
      global
      cmake
    ];

    xdg.configFile."emacs/private" = {
      source = ./emacs;
      recursive = true;
    };

    xdg.configFile."emacs/private/user-init.el" = {
      text = let
        bin = (pkgs.symlinkJoin {
          name = "editor-env-bin";
          paths = cfg.env.bin.packages;
        }) + "/bin";
      in ''
        ${concatStringsSep "\n"
        (mapAttrsToList (k: v: ''(setenv "${k}" "${v}")'') cfg.env.vars)}
        (setenv "PATH" (concat "${bin}:" (getenv "PATH")))
        (add-to-list 'exec-path "${bin}" t)
        ${cfg.emacs.setup}
      '';
    };

    programs.emacs = {
      enable = true;

      package = (pkgs.emacs.override {
        # Use gtk3 instead of the default gtk2
        withGTK3 = true;
        withGTK2 = false;
      }).overrideAttrs (attrs: rec {
        # Use emacsclient in the .desktop file
        postInstall = (attrs.postInstall or "") + ''
          ${pkgs.gnused}/bin/sed -i 's/Exec=emacs/Exec=emacsclient -c -a emacs/' $out/share/applications/emacs.desktop
        '';
      });
    };

    services.emacs = {
      enable = true;
      socketActivation.enable = true;
    };

    home.activation.spacemacs-setup =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [ -e ~/.config/emacs ] ; then
          $DRY_RUN_CMD git \
            clone $VERBOSE_ARG \
            -b ${escapeShellArg cfg.emacs.spacemacs.ref} \
            https://github.com/syl20bnr/spacemacs \
            ~/.config/emacs
        fi
        if ! [ -e ~/.config/emacs/.git ] ; then
          temp=$(mktemp -d)
          mv ~/.config/emacs/private "$temp"
          $DRY_RUN_CMD git \
            clone $VERBOSE_ARG \
            -b ${escapeShellArg cfg.emacs.spacemacs.ref} \
            https://github.com/syl20bnr/spacemacs \
            ~/.config/emacs
          rm -r ~/.config/emacs/private
          mv "$temp"/private ~/.config/emacs
          rm -r "$temp"
        fi
        $DRY_RUN_CMD git \
          --git-dir ~/.config/emacs/.git \
          --work-tree ~/.config/emacs \
          fetch $VERBOSE_ARG \
          origin \
          ${escapeShellArg cfg.emacs.spacemacs.ref}
        $DRY_RUN_CMD git \
          --git-dir ~/.config/emacs/.git \
          --work-tree ~/.config/emacs \
          update-ref \
          refs/heads/${escapeShellArg cfg.emacs.spacemacs.ref} \
          ${escapeShellArg cfg.emacs.spacemacs.rev}
        $DRY_RUN_CMD git \
          --git-dir ~/.config/emacs/.git \
          --work-tree ~/.config/emacs \
          checkout \
          ${escapeShellArg cfg.emacs.spacemacs.ref}
      '';

    home.activation.org-mode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -L ~/org ] ; then
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ~/media/keybase/private/myhlamaeus/org \
          ~/org
      fi
    '';

    systemd.user.services.emacs.Service.Requires =
      "gpg-agent.service basic.target -.slice";
    systemd.user.services.emacs.Service.Environment =
      [ "SPACEMACSDIR=${config.home.sessionVariables.SPACEMACSDIR}" ];

    home.packages = with pkgs;
      [
        (makeDesktopItem rec {
          name = "org-protocol";
          desktopName = name;
          exec = "emacsclient %u";
          categories = "System;";
          mimeType = "x-scheme-handler/org-protocol;";
        })
      ];
    xdg.mimeApps = {
      defaultApplications = {
        "x-scheme-handler/org-protocol" = "org-protocol.desktop";
      };
    };

    home.sessionVariables = {
      SPACEMACSDIR = "/home/Myhlamaeus/.config/spacemacs";
    };
  };
}
