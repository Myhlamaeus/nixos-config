{ pkgs, ... }:

with pkgs;

let
  mapAttrsToString = f: as: lib.strings.concatStrings (lib.attrsets.mapAttrsToList f as);
  xmonadConfig = config: replacements:
    stdenv.mkDerivation {
      name = "xmonad-config";
      buildInputs = with pkgs; [ makeWrapper ];

      unpackPhase = "true";
      buildPhase = ''
          cp "${config}" xmonad.hs
        ''
      + mapAttrsToString (
          name: value: ''
              sed -i "s#${name}#${value}#g" xmonad.hs
            ''
        ) replacements
      ;
      installPhase = ''
          cp xmonad.hs "$out"
        '';
    };
  xmobar = config:
    stdenv.mkDerivation {
      name = "xmobar-with-config";
      buildInputs = with pkgs; [ makeWrapper ];

      unpackPhase = "true";
      installPhase = ''
          mkdir -p "$out/bin"

          makeWrapper "${pkgs.haskellPackages.xmobar}/bin/xmobar" "$out/bin/xmobar" \
            --add-flags "\"${config}\""
        '';
    };

in
{
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = xmonadConfig
      ./xmonad.hs
      {
        xmobar-with-config = (xmobar ./xmobar.hs) + /bin/xmobar;
        rofi = "${pkgs.rofi}/bin/rofi";
        xautolock = "${pkgs.xautolock}/bin/xautolock";
      };
  };
}
