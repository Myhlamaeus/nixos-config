{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.editors;

in
{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./lang
  ];

  options.custom.editors = {
    env = {
      bin.packages = mkOption {
        type = with types; listOf package;
      };

      vars = mkOption {
        type = with types; attrsOf str;
      };
    };
  };

  config = {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "emacsclient -c -a emacs";
    };
  };
}
