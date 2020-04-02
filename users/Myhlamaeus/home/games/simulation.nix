{ config, pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  config.home.packages = lib.mkIf config.custom.games.enable (
    (
      with pkgs; [
        openrct2
        openttd
      ]
    )
    ++ (
          with pkgs-unstable; [
            dwarf-fortress-packages.dwarf-fortress-full
          ]
        )
  );
}
