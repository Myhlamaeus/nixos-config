{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      browserpass
    ];
  };
  programs.browserpass.browsers = [ "firefox" ];

  home.packages = with pkgs; [
    (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
  ];
}
