{ config, pkgs, lib, ... }:

with lib;

{
  config.custom.games.packages = with pkgs; [ crawl ];
}
