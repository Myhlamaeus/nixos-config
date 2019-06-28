{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
  {
    home-manager.users.Myhlamaeus = {
      home.packages =
        (with pkgs; [
          openra
          openrct2
          openttd
          zeroad
        ]) ++ (with pkgs-unstable; [
          linux-steam-integration
          openmw
        ]);
    };
  }
