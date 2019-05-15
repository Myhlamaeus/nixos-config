{ pkgs, lib, ... }:

{
  home-manager.users.Myhlamaeus = {
    home.packages = with pkgs; [
      linux-steam-integration
    ];
  };
}
