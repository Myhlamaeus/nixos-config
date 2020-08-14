{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.webdav;

in
{
  options.custom.webdav = {
    enable = mkEnableOption "custom.webdav";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    webdavHostname = mkOption {
      type = with types; str;
      default = "webdav.${ cfg.serverName }";
    };

    caldavHostname = mkOption {
      type = with types; str;
      default = "caldav.${ cfg.serverName }";
    };

    carddavHostname = mkOption {
      type = with types; str;
      default = "carddav.${ cfg.serverName }";
    };

    radicalePort = mkOption {
      type = with types; port;
      default = 5232;
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
        ${ cfg.serverName } = {
          enableACME = true;
          forceSSL = true;

          locations."= /.well-known/webdav".return =
            "https://${ cfg.webdavHostname }$request_uri";
          locations."= /.well-known/caldav".return =
            "https://${ cfg.caldavHostname }/";
          locations."= /.well-known/carddav".return =
            "https://${ cfg.carddavHostname }/";
        };

        ${ cfg.webdavHostname } = {
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

        ${ cfg.caldavHostname } = {
          enableACME = true;
          forceSSL = true;

          # serverAliases = [ cfg.carddavHostname ];


          basicAuthFile = "/etc/nginx/auth/caldav-users.passwd";

          locations."/" = {
            proxyPass = "http://127.0.0.1:${ toString cfg.radicalePort }";
            extraConfig = ''
              proxy_buffering on;
              proxy_set_header X-Remote-User $remote_user;
            '';
          };
        };
      };
    };

    services.radicale = {
      enable = true;

      package = pkgs.radicale2.overrideAttrs (oldAtts: {
        propagatedBuildInputs = pkgs.radicale.propagatedBuildInputs ++ (with pkgs.python38Packages; [ radicale_infcloud pytz ]);
      });

      config = ''
        [server]
        hosts = 127.0.0.1:${ toString cfg.radicalePort }
        pid = /run/radicale.pid

        ssl = False

        # This needs to change if served from a subdirectory instead of a
        # subdomain
        # base_prefix = /

        [encoding]
        request = utf-8
        stock = utf-8

        [auth]
        type = http_x_remote_user

        [rights]
        type = owner_only

        [storage]
        # type = filesystem
        filesystem_folder = /var/lib/radicale/collections

        [web]
        type = radicale_infcloud
      '';
    };
  };
}
