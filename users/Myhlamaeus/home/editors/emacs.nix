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

    spacemacs.rev = mkOption {
      type = with types; str;
      default = "develop";
    };
  };

  config = {
    custom.editors.env.bin.packages = with pkgs; [ gnuplot ];

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
        srcRepo = true;
      }).overrideAttrs (attrs: {
        name = "emacs-27.0.90-git";
        pname = "emacs";
        version = "27.0.90";
        versionModifier = "-git";
        src = pkgs.fetchFromGitHub {
          owner = "emacs-mirror";
          repo = "emacs";
          rev = "c5f255d68156926923232b1edadf50faac527861";
          sha256 = "13n82lxbhmkcmlzbh0nml8ydxyfvz8g7wsdq7nszlwmq914gb5nk";
        };
        patches = [ ];

        # Use emacsclient in the .desktop file
        postInstall = (attrs.postInstall or "") + ''
          ${pkgs.gnused}/bin/sed -i 's/Exec=emacs/Exec=emacsclient -c -a emacs/' $out/share/applications/emacs.desktop
        '';
      });
    };

    services.emacs.enable = true;

    systemd.user.services.spacemacs-setup = {
      Unit = {
        Wants = [ "home-manager-Myhlamaeus.service" ];
        After = [ "home-manager-Myhlamaeus.service" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        SyslogIdentifier = "spacemacs-setup";

        # The activation script is run by a login shell to make sure
        # that the user is given a sane Nix environment.
        ExecStart = builtins.toString (pkgs.writeScript "activate-spacemacs-setup" ''
          #! ${pkgs.stdenv.shell} -el
          if ! [ -e ~/.emacs.d ] ; then
            echo "Setting up spacemacs config"
            git clone -b ${cfg.emacs.spacemacs.rev} https://github.com/syl20bnr/spacemacs ~/.emacs.d
          fi
          if ! [ -e ~/.spacemacs ] ; then
            ln -s ${../../spacemacs} ~/.spacemacs
          fi
          git --git-dir ~/.emacs.d/.git --work-tree ~/.emacs.d fetch origin master
          git --git-dir ~/.emacs.d/.git --work-tree ~/.emacs.d checkout d95d41f55
        '');
      };

      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };

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
