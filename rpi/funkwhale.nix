{ config, pkgs, lib, ... }:

with lib;

let cfg = config.custom.funkwhale;

in {
  options.custom.funkwhale = {
    enable = mkEnableOption "custom.funkwhale";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    funkwhaleHostname = mkOption {
      type = with types; str;
      default = "funkwhale.${cfg.serverName}";
    };
  };

  config = mkIf cfg.enable {
    services.funkwhale = {
      enable = true;
      hostname = cfg.funkwhaleHostname;
      defaultFromEmail = "noreply@${cfg.funkwhaleHostname}";
      protocol = "https";
      # forceSSL = false; # uncomment when LetsEncrypt needs to access "http:" in order to check domain
      api = {
        # Generate one using `openssl rand -base64 45`, for example
        djangoSecretKey =
          "rtO19wBa9dropjCio33E+w8xU4EOOMftc9GXYKFFTRLA4qaloZDtxeAn6f9i";
      };
    };

    users.users.funkwhale.isSystemUser = true;

    # Overrides default 30M
    services.nginx.clientMaxBodySize = "250m";
  };
}
