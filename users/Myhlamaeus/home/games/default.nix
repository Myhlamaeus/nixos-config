{ pkgs, lib, ... }:

{
  imports = [ ./platforms.nix ./rpgs.nix ./rts.nix ./simulation.nix ];
}
