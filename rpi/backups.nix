{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.matrix-synapse;

in
{
  options.custom.backups = {
    enable = mkEnableOption "custom.backups";
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent.enable = true;

    services.duplicity = {
      enable = true;
      include = [ "/home" "/var" "/etc" ];
      exclude = [ "/" ];
      secretFile = /var/lib/duplicity/secret;
      targetUrl = "b2://0339f0142cfa@myhlamaeus-backup/${ config.networking.hostName }.${ config.networking.domain }/";
      extraFlags = [
        "--encrypt-key" "14F6ED45E324968B4F0E33AE71B446A5A29587FB"
        "--sign-key" "14F6ED45E324968B4F0E33AE71B446A5A29587FB"
      ];
    };
  };
}
