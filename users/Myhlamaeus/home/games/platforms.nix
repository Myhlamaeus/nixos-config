{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  home-manager.users.Myhlamaeus = {
    home.packages =
      (
        with pkgs; [
        ]
      )
      ++ (
           with pkgs-unstable; [
             linux-steam-integration
           ]
         )
    ;
  };
}
