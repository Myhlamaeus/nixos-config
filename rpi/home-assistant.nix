{ config, pkgs, lib, ... }:

with lib;

let cfg = config.custom.home-assistant;

in {
  options.custom.home-assistant = {
    enable = mkEnableOption "custom.home-assistant";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    homeAssistantHostname = mkOption {
      type = with types; str;
      default = "home.${cfg.serverName}";
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
          external_url = "https://${cfg.homeAssistantHostname}";
          internal_url = "https://${cfg.homeAssistantHostname}";
        };

        default_config = { };
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

        sensor = [{
          platform = "time_date";
          display_options = [ "time" ];
        }];

        scene = [
          {
            name = "Wake-up";
            entities = {
              "light.bedroom" = {
                state = "on";
                transition = 600;
                brightness_pct = 100;
                kelvin = 4000;
              };
            };
          }

          {
            name = "Away bedroom";
            entities = { "light.bedroom" = { state = "off"; }; };
          }

          {
            name = "Day bedroom";
            entities = { "light.bedroom" = { state = "off"; }; };
          }

          {
            name = "Evening bedroom";
            entities = {
              "light.bedroom" = {
                state = "on";
                transition = 600;
                brightness_pct = 80;
                kelvin = 3000;
              };
            };
          }

          {
            name = "Night bedroom";
            entities = {
              "light.bedroom" = {
                state = "on";
                transition = 600;
                brightness_pct = 40;
                kelvin = 2000;
              };
            };
          }
        ];

        automation = [
          {
            alias = "Wake-up";

            trigger = {
              platform = "time";
              at = "04:00:00";
            };

            condition = [{
              condition = "state";
              entity_id = "person.maurice";
              state = "home";
            }];

            action = [{
              service = "scene.turn_on";
              entity_id = "scene.wake_up";
            }];
          }

          {
            alias = "Day Bedroom";

            trigger = {
              platform = "time";
              at = "07:00:00";
            };

            action = {
              service = "scene.turn_on";
              entity_id = "scene.day_bedroom";
            };
          }

          {
            alias = "Evening Bedroom";

            trigger = [
              {
                platform = "sun";
                event = "sunset";
                offset = "-01:00:00";
              }

              {
                platform = "state";
                entity_id = "person.maurice";
                to = "home";
              }
            ];

            condition = [
              {
                condition = "state";
                entity_id = "person.maurice";
                state = "home";
              }

              {
                condition = "time";
                after = "16:00:00";
                before = "18:00:00";
              }
            ];

            action = {
              service = "scene.turn_on";
              entity_id = "scene.evening_bedroom";
            };
          }

          {
            alias = "Night Bedroom";

            trigger = [
              {
                platform = "time";
                at = "18:00:00";
              }

              {
                platform = "state";
                entity_id = "person.maurice";
                to = "home";
              }
            ];

            condition = [
              {
                condition = "state";
                entity_id = "person.maurice";
                state = "home";
              }

              {
                condition = "time";
                after = "18:00:00";
              }
            ];

            action = {
              service = "scene.turn_on";
              entity_id = "scene.night_bedroom";
            };
          }

          {
            alias = "Away Bedroom";

            trigger = {
              platform = "state";
              entity_id = "person.maurice";
              to = "not_home";
            };

            action = {
              service = "scene.turn_on";
              entity_id = "scene.away_bedroom";
            };
          }
        ];
      };
      # configWritable = true; # doesn't work atm
    };

    services.nginx.virtualHosts.${cfg.homeAssistantHostname} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.homeAssistantPort}";
        proxyWebsockets = true;
      };
    };
  };
}
