{ config, pkgs, lib, ... }:

with lib;

let cfg = config.custom.grocy;

in {
  options.custom.grocy = {
    enable = mkEnableOption "custom.grocy";

    serverName = mkOption {
      type = with types; str;
      default = config.networking.domain;
    };

    grocyHostname = mkOption {
      type = with types; str;
      default = "grocy.${cfg.serverName}";
    };
  };

  config = mkIf cfg.enable {
    services.grocy = {
      enable = true;

      hostName = cfg.grocyHostname;

      settings = {
        currency = "EUR";
        culture = "de";

        calendar = {
          showWeekNumber = true;
          firstDayOfWeek = 1;
        };
      };
    };
  };
}
