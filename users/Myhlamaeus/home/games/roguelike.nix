{ config, pkgs, lib, ... }:

{
  config.custom.games.packages = with pkgs; [
      crawl
    ]
  ;
}
