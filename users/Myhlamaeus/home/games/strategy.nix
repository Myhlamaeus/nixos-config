{ config, pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  config.home.packages = lib.mkIf config.custom.games.enable (
    (
      with pkgs; [
        openra
        zeroad
        hedgewars
      ]
    )
    ++ (
          with pkgs-unstable; [
          ]
        )
  );
}