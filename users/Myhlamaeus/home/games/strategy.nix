{ config, pkgs, lib, ... }:

with lib;

{
  config.custom.games.packages = with pkgs;
    optionals config.custom.x11.enable [ openra zeroad hedgewars ];
}
