{ pkgs, ... }:

{
  home-manager.users.Myhlamaeus = {
    programs.firefox = {
      enable = true;

      # Not yet in 18.09
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   https-everywhere
      # ];
    };

    home.packages = with pkgs; [ tor-browser-bundle ];
  };
}
