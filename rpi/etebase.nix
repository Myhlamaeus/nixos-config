{ config, pkgs, lib, ... }:

with lib;

let cfg = config.custom.etebase;

in {
  options.custom.etebase = {
    enable = mkEnableOption "custom.etebase";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    etebaseHostname = mkOption {
      type = with types; str;
      default = "etebase.${cfg.serverName}";
    };

    etebasePort = mkOption {
      type = with types; port;
      default = 8001;
    };
  };

  config = mkIf cfg.enable {
    services.etebase-server = {
      enable = true;
      port = cfg.etebasePort;
      settings = {
        global = { secret_file = "/etc/nixos/secrets/etebase-server"; };
        allowed_hosts = { allowed_host1 = cfg.etebaseHostname; };
      };
    };

    services.nginx.virtualHosts.${cfg.etebaseHostname} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.etebasePort}";
        proxyWebsockets = true;
      };
    };
  };
}
