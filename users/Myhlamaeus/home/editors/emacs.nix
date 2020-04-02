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

    systemd.user.services.emacs.Service.Requires = "gpg-agent.service basic.target -.slice";
  };
}
