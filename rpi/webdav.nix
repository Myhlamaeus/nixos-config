{ config, pkgs, lib, ... }:

with lib;

let cfg = config.custom.webdav;

in {
  options.custom.webdav = {
    enable = mkEnableOption "custom.webdav";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    webdavHostname = mkOption {
      type = with types; str;
      default = "webdav.${cfg.serverName}";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      appendHttpConfig = ''
        dav_ext_lock_zone zone=lock:10m;
      '';

      virtualHosts = {
        ${cfg.serverName} = {
          enableACME = true;
          forceSSL = true;

          locations."= /.well-known/webdav".return =
            "https://${cfg.webdavHostname}$request_uri";
        };

        ${cfg.webdavHostname} = {
          enableACME = true;
          forceSSL = true;

          basicAuthFile = "/etc/nginx/auth/webdav-users.passwd";

          root = "/var/www/webdav";

          locations."/".extraConfig = ''
            # enable creating directories without trailing slash
            set $x $uri$request_method;
            if ($x ~ [^/]MKCOL$) {
              rewrite ^(.*)$ $1/;
            }

            client_body_temp_path /var/tmp/webdav;

            dav_methods PUT DELETE MKCOL COPY MOVE;
            dav_ext_methods PROPFIND OPTIONS;
            # dav_ext_lock zone=lock;

            create_full_put_path on;
            dav_access user:rw;

            autoindex on;
          '';
        };
      };
    };
  };
}
