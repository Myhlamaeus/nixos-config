{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  home.packages =
    (
      with pkgs; [
        openra
        zeroad
      ]
    )
    ++ (
          with pkgs-unstable; [
          ]
        )
  ;
}
