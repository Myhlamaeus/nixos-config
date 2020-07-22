{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "fhgenkpocbhhddlgkjnfghpjanffonno" # Authy Chrome Extension
      # "agoopbiflnjadjfbhimhlmcbgmdgldld" # Baseliner
      "naepdomgkenhinolocfifgehidddafch" # Browserpass
      # "jifpbeccnghkjeaalbbjmodiffmgedin" # Chrome extension source viewer
      # "inomeogfingihgjfjlpeplalcfajhgai" # Chrome Remote Desktop
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      # "okadibdjfemgnhjiembecghcbfknbfhg" # Enhanced Steam
      # "pioclpoplcdbaefihamjohnefbikjilc" # Evernote Web Clipper
      "hoccpcefjcgnabbmojbfoflggkecmpgd" # github-vscode-icons
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly for Chrome
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "bjfhmglciegochdpefhhlphglcehbmek" # Hypothesis - Web & PDF Annotation
      "gbmdgpbipfallnflgajpaliibnhdgobh" # JSON Viewer
      # "flcpelgcagfhfoegekianiofphddckof" # KB SSL Enforcer
      # "mahhgdkliaknjffpmocpaglcoljnhodn" # Memrise Button
      "lmjdlojahmbbcodnpecnjnmlddbkjhnn" # Notifier for GitHub
      "kkkjlfejijcjgjllecmnejhogpbcigdc" # Org Capture
      "chlffgpmiacpedhhbkiomidkjlcfhogd" # Pushbullet
      # "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
      # "lmhkpmbekcpmknklioeibfkpmmfibljd" # Redux DevTools
      "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
      # "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
      # "nlnkcinjjeoojlhdiedbbolilahmnldj" # Tab Sorter
      "eggkanocgddhmamlbiijnphhppkpkmkl" # Tabs Outliner
      "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "bhmmomiinigofkjcapegjjndpbikblnp" # WOT Web of Trust, Website Reputation Ratings
    ];
  };
  programs.browserpass.browsers = [ "chromium" ];

  # Not yet in stable
  # systemd.user.sessionVariables = {
  home.sessionVariables = {
    BROWSER = "chromium";
  };

  home.packages = let
    makeChromiumDesktopItem = { name, desktopName, app, profileDirectory ? "Default", categories ? "" }:
      with pkgs; with lib;
      makeDesktopItem rec {
        exec = ''
          ${chromium}/bin/chromium --profile-directory=${escapeShellArg profileDirectory} --app=${escapeShellArg app}
        '';
        inherit name desktopName categories;
      };
  in
  [
    (makeChromiumDesktopItem {
      name = "youtube-music";
      desktopName = "YouTube Music";
      app = "https://music.youtube.com";
    })
  ];
}
