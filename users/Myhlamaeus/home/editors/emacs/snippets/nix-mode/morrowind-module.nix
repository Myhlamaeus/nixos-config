# -*- mode: snippet -*-
#name : MorrowindModule
#key : MorrowindModule
#contributor :
# --
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.mods.${1:`(file-name-base (directory-file-name (file-name-directory (buffer-file-name))))`};

in
{
  options.mods.$1 = {
    enable = mkEnableOption "$1";
  };

  config = mkIf cfg.enable {
    modPackages = with pkgs.morrowindMods; [
      ($1.override {
        $2
      })
    ];
  };
}
