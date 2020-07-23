{ config, pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  config.custom.games.packages = (
      with pkgs; [
        (retroarch.override {
          cores = with libretro; [ dolphin ];
        })
        steam
      ]
    )
    ++ (
        with pkgs-unstable; [
        ]
      )
  ;
}
