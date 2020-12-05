{ config, pkgs, lib, ... }:

let
  cfg = config.fonts.fontconfig;
  inherit (lib) mkOption concatMapStringsSep;
  inherit (lib.types) submodule listOf str;
  inherit (pkgs) makeDesktopItem writeScriptBin;

in {
  options.fonts.fontconfig = {
    overrides = mkOption {
      type = listOf (submodule {
        options = {
          sources = mkOption { type = listOf str; };

          targets = mkOption { type = listOf str; };

          type = mkOption {
            type = str;
            default = "prefer";
          };
        };
      });
    };
  };

  config.fonts.fontconfig.localConf = let
    aliases = { targets, sources, type }:
      concatMapStringsSep "\n" (ns: ''
        <alias binding="same">
          <family>${ns}</family>
          <${type}>
            ${concatMapStringsSep "\n" (nt: "<family>${nt}</family>") targets}
          </${type}>
        </alias>
      '') sources;
  in ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>
      ${concatMapStringsSep "\n" aliases cfg.overrides}
    </fontconfig>
  '';
}
