{ config, pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  config.custom.games.packages = (
      with pkgs; [
        openrct2
        openttd
      ]
    )
    ++ (
        with pkgs-unstable; [
          (dwarf-fortress-packages.dwarf-fortress-full.override {
            theme = null;
          })
        ]
      )
  ;
}
