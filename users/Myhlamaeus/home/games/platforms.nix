{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    custom.games.packages = with pkgs;
      optionals config.custom.x11.enable [
        (retroarch.override { cores = with libretro; [ dolphin ]; })
        steam
      ];

    home.file.".steam/root/compatibilitytools.d/proton-ge-custom" = {
      source = pkgs.proton-ge-custom;
    };
  };
}
