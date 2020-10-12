{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.home-assistant;

in
{
  options.custom.home-assistant = {
    enable = mkEnableOption "custom.home-assistant";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    homeAssistantHostname = mkOption {
      type = with types; str;
      default = "home.${ cfg.serverName }";
    };

    homeAssistantPort = mkOption {
      type = with types; port;
      default = 8123;
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;

      package = pkgs.home-assistant.override {
        extraPackages = ps: [ (ps.callPackage pkgs.pydeconz { }) ];
      };

      openFirewall = true;

      config = {
        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          time_zone = "UTC";
          temperature_unit = "C";
          external_url = "https://${ cfg.homeAssistantHostname }";
          internal_url = "https://${ cfg.homeAssistantHostname }";
        };

        default_config = {};
        # sensor = [
        #   # missing input
        #   # {
        #   #   platform = "coronavirus";
        #   #   # country = "de";
        #   # }
        # ];

        # owntracks = {
        #   mqtt_topic = "owntracks/#";
	      #   secret = "!secret owntracks_secret";
        # };

        deconz = {
          host = "localhost";
          port = config.local.services.deconz.httpPort;
          api_key = "!secret deconzSecret";
        };
      };
      # configWritable = true; # doesn't work atm
    };

    services.nginx.virtualHosts.${ cfg.homeAssistantHostname } = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${ toString cfg.homeAssistantPort }";
        proxyWebsockets = true;
      };
    };
  };
}
