{ config, pkgs, lib, ... }:

with lib; {
  config = mkIf config.custom.x11.enable {
    programs.chromium = {
      enable = true;
      extensions = [
        "naepdomgkenhinolocfifgehidddafch" # Browserpass
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
    };
    programs.browserpass.browsers = [ "chromium" ];
  };
}
