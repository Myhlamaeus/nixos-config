{ config, pkgs, lib, ... }:

{
  config.home.packages = lib.mkIf config.custom.games.enable (
    with pkgs; [
      crawl
    ]
  );
}
