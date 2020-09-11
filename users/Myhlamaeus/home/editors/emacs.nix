{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.editors;

in
{
  options.custom.editors.emacs = {
    setup = mkOption {
      type = with types; lines;
    };

    spacemacs = {
      ref = mkOption {
        type = with types; str;
        default = "develop";
      };
      rev = mkOption {
        type = with types; str;
        default = "9d4633a3c";
      };
    };
  };

  config = {
    custom.editors.env.bin.packages = with pkgs; [ gnuplot unzip texlive.combined.scheme-full ];

    home.file.".emacs.d/private" = {
      source = ./emacs;
      recursive = true;
    };

    home.file.".emacs.d/private/user-init.el" = {
      text =
        let
          bin = (pkgs.symlinkJoin {
            name = "editor-env-bin";
            paths = cfg.env.bin.packages;
          }) + "/bin";
        in
        ''
          ${concatStringsSep "\n" (mapAttrsToList (k: v: ''(setenv "${k}" "${v}")'') cfg.env.vars)}
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

    services.emacs.enable = true;

    home.activation.spacemacs-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! [ -e ~/.emacs.d ] ; then
        $DRY_RUN_CMD git \
          clone $VERBOSE_ARG \
          -b ${escapeShellArg cfg.emacs.spacemacs.ref} \
          https://github.com/syl20bnr/spacemacs \
          ~/.emacs.d
      fi
      if ! [ -e ~/.emacs.d/.git ] ; then
        local temp=$(mktemp -d)
        mv ~/.emacs.d/private "$temp"
        $DRY_RUN_CMD git \
          clone $VERBOSE_ARG \
          -b ${escapeShellArg cfg.emacs.spacemacs.ref} \
          https://github.com/syl20bnr/spacemacs \
          ~/.emacs.d
        rm -r ~/.emacs.d/private
        mv "$temp"/private ~/.emacs.d
        rm -r "$temp"
      fi
      if ! [ -e ~/.spacemacs ] ; then
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          /etc/nixos/config/users/Myhlamaeus/spacemacs \
          ~/.spacemacs
      fi
      $DRY_RUN_CMD git \
        --git-dir ~/.emacs.d/.git \
        --work-tree ~/.emacs.d \
        fetch $VERBOSE_ARG \
        origin \
        ${escapeShellArg cfg.emacs.spacemacs.ref}
      $DRY_RUN_CMD git \
        --git-dir ~/.emacs.d/.git \
        --work-tree ~/.emacs.d \
        update-ref \
        refs/heads/${escapeShellArg cfg.emacs.spacemacs.ref} \
        ${escapeShellArg cfg.emacs.spacemacs.rev}
      $DRY_RUN_CMD git \
        --git-dir ~/.emacs.d/.git \
        --work-tree ~/.emacs.d \
        checkout \
        ${escapeShellArg cfg.emacs.spacemacs.ref}
    '';

    home.activation.org-mode = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! [ -e ~/org ] ; then
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ~/media/keybase/private/myhlamaeus/org \
          ~/org
      fi
    '';

    systemd.user.services.emacs.Service.Requires = "gpg-agent.service basic.target -.slice";

    home.packages = with pkgs; [
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
  };
}
