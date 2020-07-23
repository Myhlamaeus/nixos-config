{ config, pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  config.custom.games.packages = (
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
  ;
}
