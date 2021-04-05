{ config, pkgs, lib, ... }:

let
  cfg = config.programs.firefox.autoProfile;
  inherit (lib)
    types mkIf mkEnableOption mkOption replaceStrings flatten mapAttrsToList
    nameValuePair concatMapStringsSep concatStringsSep elem optionalString
    filterAttrs listToAttrs concatMap;
  inherit (types) attrsOf listOf str;
  inherit (pkgs) makeDesktopItem writeScriptBin;
  attrsToList = v: flatten (mapAttrsToList (k: map (nameValuePair k)) v);
  concatMapAttrsToString = sep: f: v:
    concatMapStringsSep sep ({ name, value }: f name value) (attrsToList v);
  listToAttrs' = pairs:
    listToAttrs
    (concatMap ({ names, value }: map (name: nameValuePair name value) names)
      pairs);
  firefoxAuto = writeScriptBin "firefox-auto" ''
    url=$1
    profile=
    matchUrl=''${url#"http://"}
    matchUrl=''${matchUrl#"https://"}
    case "''${matchUrl}" in
      ${
        concatMapAttrsToString "\n  " (k: v: "${v}) profile=${k} ;;")
        cfg.associations
      }
      *) profile=$(echo -e "private\nwork\nsecret" | ${cfg.dmenu}) ;;
    esac
    if [[ $profile == "" ]] ; then
      firefox "$url"
    else
      firefox -P "$profile" "$url"
    fi
  '';
  makeBaseDesktopItem = attrs:
    makeDesktopItem ({
      icon = "firefox";
      mimeType =
        "text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
      genericName = "Web Browser";
      categories = "Application;Network;WebBrowser";
    } // attrs);
  firefoxAutoDesktop = makeBaseDesktopItem {
    name = "firefox-auto";
    desktopName = "Firefox (automatic profile)";
    exec = "${firefoxAuto}/bin/firefox-auto %U";
  };
  escapeDesktopArg = arg: replaceStrings [ ''"'' ] [ ''"\""'' ] (toString arg);
  mkProfileExec = { app ? null, profile ? null, ... }: ''
    firefox ${
      optionalString (profile != null) ''-P "${escapeDesktopArg profile}"''
    } ${optionalString (app != null) ''--ssb="${escapeDesktopArg app}"''} %U
  '';
  mkProfileDesktopItem = attrs:
    makeBaseDesktopItem ((removeAttrs attrs [ "app" "profile" ]) // {
      exec = mkProfileExec attrs;
    });
  profileDesktops = mapAttrsToList (k: v:
    mkProfileDesktopItem rec {
      name = "firefox-profile-${k}";
      desktopName = "Firefox (${v.name})";
      profile = v.name;
      mimeType =
        "text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
      genericName = "Web Browser";
      categories = "Application;Network;WebBrowser";
      extraEntries = ''
        StartupWMClass="${escapeDesktopArg name}"
      '';
    }) (filterAttrs (k: v: !v.isDefault) config.programs.firefox.profiles);

in {
  options.programs.firefox.autoProfile = {
    enable = mkEnableOption "firefoxAutoProfile";

    associations = mkOption { type = attrsOf (listOf str); };

    defaultApplicationFor = mkOption {
      type = listOf str;
      default = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
    };

    dmenu = mkOption {
      type = str;
      default = "${pkgs.rofi}/bin/rofi -dmenu";
    };
  };

  config = mkIf (config.programs.firefox.enable && cfg.enable) {
    home.packages = [ firefoxAuto firefoxAutoDesktop ] ++ profileDesktops;

    xdg.mimeApps.defaultApplications = listToAttrs' [{
      names = cfg.defaultApplicationFor;
      value = "firefox-auto.desktop";
    }];

    home.sessionVariables = mkIf
      (elem "x-scheme-handler/http" cfg.defaultApplicationFor
        && elem "x-scheme-handler/https" cfg.defaultApplicationFor) {
          BROWSER = "${firefoxAuto}/bin/firefox-auto";
        };
  };
}
