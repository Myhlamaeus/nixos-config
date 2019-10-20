{ pkgs, lib, ... }:

let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });

in
{
  home.packages =
    (
      with pkgs; [
        openrct2
        openttd
        dwarf-fortress-packages.dwarf-fortress-full
      ]
    )
    ++ (
          with pkgs-unstable; [
          ]
        )
  ;
}
