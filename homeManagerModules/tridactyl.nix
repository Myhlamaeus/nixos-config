{ config, pkgs, lib, ... }:

let
  cfg = config.programs.firefox.tridactyl;
  inherit (builtins) toJSON;
  inherit (lib)
    types mkEnableOption mkOption mkIf mapAttrsToList concatStringsSep all
    attrNames concatMapStringsSep;
  inherit (types) attrsOf str enum listOf submodule ints;
  attrsOfKeys = keyType: elemType:
    let t = attrsOf elemType;
    in t // {
      name = "attrsOfKeys";
      check = v: t.check v && all keyType.check (attrNames v);
      description =
        "attribute set with ${keyType.description} as key and ${elemType.description} as value";
    };
  concatMapAttrsToStringSep = sep: f: v:
    concatStringsSep sep (mapAttrsToList f v);
  concatMapAttrsToLines = concatMapAttrsToStringSep "\n";

in {
  options.programs.firefox.tridactyl = {
    enable = mkEnableOption "tridactyl";

    commands = mkOption {
      type = attrsOf str;
      default = { };
    };

    autoCommands = mkOption {
      type = attrsOf (attrsOfKeys
        # Copied from :help
        (enum [
          "TriStart"
          "DocStart"
          "DocLoad"
          "DocEnd"
          "TabEnter"
          "TabLeft"
          "FullscreenChange"
          "FullscreenEnter"
          "FullscreenLeft"
          "AuthRequired"
          "BeforeRedirect"
          "BeforeRequest"
          "BeforeSendHeaders"
          "Completed"
          "ErrorOccured"
          "HeadersReceived"
          "ResponseStarted"
          "SendHeaders"
        ]) (listOf str));
      default = { };
    };

    bindings = mkOption {
      type = attrsOf str;
      default = { };
    };

    urlBindings = mkOption {
      type = attrsOf (attrsOf str);
      default = { };
    };

    searchUrls = mkOption {
      type = attrsOf str;
      default = { };
    };

    theme = mkOption {
      type = str;
      default = "light";
    };

    enableSmoothScroll = mkEnableOption "smoothScroll";

    hint = mkOption {
      type = submodule {
        options = {
          filterMode = mkOption {
            type = enum [ "simple" "vimperator" "vimperator-reflow" ];
            default = "simple";
          };

          names = mkOption {
            type = enum [ "short" "uniform" "numeric" ];
            default = "short";
          };

          delay = mkOption {
            type = ints.positive;
            default = 300;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.firefox.tridactyl.theme =
      if config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme then
        "dark"
      else
        "light";

    home.file.".mozilla/native-messaging-hosts/tridactyl.json".source =
      "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";

    xdg.configFile."tridactyl/tridactylrc".text = ''
      ${concatMapAttrsToLines (k: v: "command ${k} ${v}") cfg.commands}
      ${concatMapAttrsToLines (k:
        concatMapAttrsToLines
        (k2: (concatMapStringsSep "\n" (v: "autocmd ${k2} ${k} ${v}"))))
      cfg.autoCommands}

      ${concatMapAttrsToLines (k: v: "bind ${k} ${v}") cfg.bindings}
      ${concatMapAttrsToLines
      (k: concatMapAttrsToLines (k2: v: "bindurl ${k} ${k2} ${v}"))
      cfg.urlBindings}

      set searchurls {}
      ${concatMapAttrsToLines (k: v: "set searchurls.${k} ${v}") cfg.searchUrls}

      set colourscheme ${cfg.theme}
      set smoothscroll ${toJSON cfg.enableSmoothScroll}

      set hintfiltermode ${cfg.hint.filterMode}
      set hintnames ${cfg.hint.names}
      set hintdelay ${toString cfg.hint.delay}
    '';
  };
}
