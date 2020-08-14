{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.home-assistant;

in
{
  options.custom.home-assistant = {
    enable = mkEnableOption "custom.home-assistant";
  };

  config = mkIf cfg.enable {
    services.openhome-assistant = {
      enable = true;
    }
  };
}
