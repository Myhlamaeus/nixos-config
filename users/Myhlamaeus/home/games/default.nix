{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.games;

in
{
  imports = [
    ./platforms.nix
    ./roguelike.nix
    ./rpgs.nix
    ./strategy.nix
    ./simulation.nix
  ];

  options.custom.games = {
    enable = mkEnableOption "games";

    packages = {
      type = with types; listOf package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    # Not sure why, but this errors with 'value is a list while a set
    # was expected', even though home.packages has the same type as
    # custom.games.packages
    # home.packages = cfg.packages;
  };
}
