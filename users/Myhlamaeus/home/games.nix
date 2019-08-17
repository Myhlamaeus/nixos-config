{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  home-manager.users.Myhlamaeus = {
    home.packages =
      (
        with pkgs; [
          openra
          openrct2
          openttd
          zeroad
          dwarf-fortress-packages.dwarf-fortress-full
        ]
      )
      ++ (
           with pkgs-unstable; [
             linux-steam-integration
             openmw
           ]
         )
    ;
  };
}
