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
    ./other.nix
  ];

  options.custom.games = {
    enable = mkEnableOption "games";

    packages = mkOption {
      type = with types; listOf package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages;
  };
}
