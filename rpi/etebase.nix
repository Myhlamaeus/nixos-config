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

    etebaseSocket = mkOption {
      type = with types; str;
      default = "/run/etebase-server/etebase-server.sock";
    };
  };

  config = mkIf cfg.enable {
    services.etebase-server = {
      enable = true;
      port = null;
      unixSocket = cfg.etebaseSocket;
      settings = {
        global = { secret_file = "/etc/nixos/secrets/etebase-server"; };
        allowed_hosts = { allowed_host1 = cfg.etebaseHostname; };
      };
    };

    services.nginx = {
      virtualHosts."${cfg.etebaseHostname}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = cfg.etebaseSocket;
      };
    };

    systemd.services.etebase-server.preStart = ''
      mkdir -p /run/etebase-server
    '';
  };
}
