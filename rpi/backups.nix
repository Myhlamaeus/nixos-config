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
      exclude = [ "/tmp" ];
      secretFile = /root/duplicitySecret;
      targetUrl = "pydrive+gdocs://google-drive-backup@hale-structure-285320.iam.gserviceaccount.com@developer.gserviceaccount.com/backups/${ config.networking.hostName }.${ config.networking.domain }/";
      extraFlags = [
        "--encrypt-key" "7FCB362E2D975AD2A45A682CAD1390B6FE33C758"
        "--sign-key" "14F6ED45E324968B4F0E33AE71B446A5A29587FB"
      ];
    };
  };
}
