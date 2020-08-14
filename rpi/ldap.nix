{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.ldap;

in
{
  options.custom.ldap = {
    enable = mkEnableOption "custom.ldap";
  };

  config = mkIf cfg.enable {
    services.openldap = {
      enable = true;
    }
  };
}
