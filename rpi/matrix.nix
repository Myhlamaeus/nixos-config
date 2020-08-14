{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.matrix-synapse;

in
{
  options.custom.matrix-synapse = {
    enable = mkEnableOption "custom.matrix-synapse";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    matrixHostname = mkOption {
      type = with types; str;
      default = "matrix.${ cfg.serverName }";
    };

    synapsePort = mkOption {
      type = with types; port;
      default = 8008;
    };

    elementHostname = mkOption {
      type = with types; str;
      default = "element.${ cfg.serverName }";
    };

    turnRealm = mkOption {
      type = with types; str;
      default = "turn.${ cfg.serverName }";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "${ config.services.matrix-synapse.database_args.user }" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "${ config.services.matrix-synapse.database_args.database }" WITH OWNER "${ config.services.matrix-synapse.database_args.user }"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        ${ cfg.serverName } = {
          enableACME = true;
          forceSSL = true;

          locations."= /.well-known/matrix/server".extraConfig =
            let
              # use 443 instead of the default 8448 port to unite
              # the client-server and server-server port for simplicity
              server = { "m.server" = "${ cfg.matrixHostname }:443"; };
            in ''
              add_header Content-Type application/json;
              return 200 '${ builtins.toJSON server }';
            '';

          locations."= /.well-known/matrix/client".extraConfig =
            let
              client = {
                "m.homeserver" =  { "base_url" = "https://${ cfg.matrixHostname }"; };
                "m.identity_server" =  { "base_url" = "https://vector.im"; };
              };
            # ACAO required to allow element-web on any URL to request this json file
            in ''
              add_header Content-Type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${ builtins.toJSON client }';
            '';
        };

        # Reverse proxy for Matrix client-server and server-server communication
        ${ cfg.matrixHostname } = {
          enableACME = true;
          forceSSL = true;

          # Or do a redirect instead of the 404, or whatever is appropriate for you.
          # But do not put a Matrix Web client here! See the Element web section below.
          locations."/".extraConfig = ''
            return 404;
          '';

          # forward all Matrix API calls to the synapse Matrix homeserver
          locations."/_matrix" = {
            proxyPass = "http://[::1]:${ toString cfg.synapsePort }"; # without a trailing /
          };
        };

        ${ cfg.elementHostname } = {
          enableACME = true;
          forceSSL = true;

          root = pkgs.element-web.override {
            conf = {
              default_server_config."m.homeserver" = {
                base_url = "https://${ cfg.matrixHostname }";
                server_name = cfg.serverName;
              };
            };
          };
        };

        ${ cfg.turnRealm } = {
          enableACME = true;
          forceSSL = true;

          locations."/".extraConfig = ''
            return 404;
          '';
        };
      };
    };

    services.matrix-synapse = {
      enable = true;
      server_name = cfg.serverName;
      registration_shared_secret = "a8Q6O65lhUeKwrcoLO5uaaLR0oorbhnuaGprzTlXbLDk8dlxTP9kHq4RRNrwG6Q2";
      listeners = [
        {
          port = cfg.synapsePort;
          bind_address = "::1";
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
      max_upload_size = "50M";

      turn_uris = mkIf config.services.coturn.enable [
        "turn:${ cfg.turnRealm }:${ toString config.services.coturn.listening-port }?transport=udp"
        "turn:${ cfg.turnRealm }:${ toString config.services.coturn.listening-port }?transport=tcp"
      ];
      turn_shared_secret = mkIf config.services.coturn.enable config.services.coturn.static-auth-secret;
      turn_user_lifetime = mkIf config.services.coturn.enable "86400000";
      extraConfig = mkIf config.services.coturn.enable ''
        turn_allow_guests: True
      '';
    };

    services.coturn = {
      enable = false;

      use-auth-secret = true;
      static-auth-secret = "gmsBDkJk7zP6Cc4qgZ0A8ruDasFeMNe2GjbfNPAB673EGmFbNvyvN1NrvGYvpUeV";
      realm = cfg.turnRealm;

      # VoIP traffic is all UDP. There is no reason to let users connect to arbitrary TCP endpoints via the relay.
      no-tcp-relay = true;

      extraConfig = ''
        # don't let the relay ever try to connect to private IP address ranges within your network (if any)
        # given the turn server is likely behind your firewall, remember to include any privileged public IPs too.
        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255
        allowed-peer-ip=10.67.3.13

        # consider whether you want to limit the quota of relayed streams per user (or total) to avoid risk of DoS.
        user-quota=12 # 4 streams per video call, so 12 streams = 3 simultaneous relayed calls per user.
        total-quota=1200
      '';

      cert = "/var/lib/acme/${ cfg.turnRealm }/fullchain.pem";
      pkey = "/var/lib/acme/${ cfg.turnRealm }/key.pem";
    };

    security.acme.certs = mkIf config.services.coturn.enable {
      ${ cfg.turnRealm } = {
        group = "turnserver";
        allowKeysForGroup = true;
        postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        config.services.coturn.listening-port
        config.services.coturn.tls-listening-port
      ];

      allowedUDPPorts = [
        config.services.coturn.listening-port
        config.services.coturn.tls-listening-port
      ];

      allowedUDPPortRanges = [
        {
          from = config.services.coturn.min-port;
          to = config.services.coturn.max-port;
        }
      ];
    };
  };
}
