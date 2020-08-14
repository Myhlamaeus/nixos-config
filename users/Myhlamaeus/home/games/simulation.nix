{ config, pkgs, lib, ... }:

with lib;

{
  config.custom.games.packages = with pkgs;
    optionals config.custom.x11.enable [
      openrct2
      openttd
      (dwarf-fortress-packages.dwarf-fortress-full.override {
        theme = null;
      })
    ]
  ;
}
