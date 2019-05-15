{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> {});

in
  {
    home-manager.users.Myhlamaeus = {
      home.packages =
        (with pkgs; [
          linux-steam-integration
          openra
          openrct2
          openttd
          zeroad
        ]) ++ (with pkgs-unstable; [
          openmw
        ]);
    };
  }
