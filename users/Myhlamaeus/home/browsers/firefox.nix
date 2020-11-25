{ config, pkgs, lib, ... }:

with lib;

let
  sharedSettings = {
    # A result of the Tor Uplift effort, this preference isolates all browser identifier sources (e.g. cookies) to the first party domain, with the goal of preventing tracking across different domains. (Don't do this if you are using the Firefox Addon "Cookie AutoDelete" with Firefox v58 or below.)
    "privacy.firstparty.isolate" = true;
    # A result of the Tor Uplift effort, this preference makes Firefox more resistant to browser fingerprinting.
    # Temporarily disabled due to prefers-color-scheme
    "privacy.resistFingerprinting" = false;
    # [FF67+] Blocks Fingerprinting
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    # [FF67+] Blocks CryptoMining
    "privacy.trackingprotection.cryptomining.enabled" = true;
    # This is Mozilla's new built-in tracking protection. One of it's benefits is blocking tracking (i.e. Google Analytics) on privileged pages where add-ons that usually do that are disabled.
    "privacy.trackingprotection.enabled" = true;
    # The attribute would be useful for letting websites track visitors' clicks.
    "browser.send_pings" = false;
    # Disable preloading of autocomplete URLs. Firefox preloads URLs that autocomplete when a user types into the address bar, which is a concern if URLs are suggested that the user does not want to connect to.
    "browser.urlbar.speculativeConnect.enabled" = false;
    # Disable that websites can get notifications if you copy, paste, or cut something from a web page, and it lets them know which part of the page had been selected.
    "dom.event.clipboardevents.enabled" = false;
    # Disables playback of DRM-controlled HTML5 content, which, if enabled, automatically downloads the Widevine Content Decryption Module provided by Google Inc. Details
    # DRM-controlled content that requires the Adobe Flash or Microsoft Silverlight NPAPI plugins will still play, if installed and enabled in Firefox.
    "media.eme.enabled" = false;
    # Disables the Widevine Content Decryption Module provided by Google Inc., used for the playback of DRM-controlled HTML5 content. Details
    "media.gmp-widevinecdm.enabled" = false;
    # Websites can track the microphone and camera status of your device.
    "media.navigator.enabled" = false;
    # Disable cookies
    # 0 = Accept all cookies by default
    # 1 = Only accept from the originating site (block third-party cookies)
    # 2 = Block all cookies by default
    "network.cookie.cookieBehavior" = 1;
    # Only send Referer header when the full hostnames match. (Note: if you notice significant breakage, you might try 1 combined with an XOriginTrimmingPolicy tweak below.)
    # 0 = Send Referer in all cases
    # 1 = Send Referer to same eTLD sites
    # 2 = Send Referer only when the full hostnames match
    "network.http.referer.XOriginPolicy" = 2;
    # When sending Referer across origins, only send scheme, host, and port in the Referer header of cross-origin requests.
    # 0 = Send full url in Referer
    # 1 = Send url without query string in Referer
    # 2 = Only send scheme, host, and port in Referer
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    # WebGL is a potential security risk.
    "webgl.disabled" = true;
    # This preference controls when to store extra information about a session: contents of forms, scrollbar positions, cookies, and POST data. Details
    # 0 = Store extra session data for any site. (Default starting with Firefox 4.)
    # 1 = Store extra session data for unencrypted (non-HTTPS) sites only. (Default before Firefox 4.)
    # 2 = Never store extra session data.
    "browser.sessionstore.privacy_level" = 2;
    # Disables sending additional analytics to web servers. Details
    "beacon.enabled" = false;
    # Prevents Firefox from sending information about downloaded executable files to Google Safe Browsing to determine whether it should be blocked for safety reasons. Details
    "browser.safebrowsing.downloads.remote.enabled" = false;
    # Disable Firefox prefetching pages it thinks you will visit next:
    # Prefetching causes cookies from the prefetched site to be loaded and other potentially unwanted behavior. Details here and here.
    "network.dns.disablePrefetch" = true;
    "network.dns.disablePrefetchFromHTTPS" = true;
    "network.predictor.enabled" = false;
    "network.predictor.enable-prefetch" = false;
    "network.prefetch-next" = false;
    # Not rendering IDNs as their Punycode equivalent leaves you open to phishing attacks that can be very difficult to notice.
    "network.IDN_show_punycode" = true;
    # Enable DNT header
    "privacy.donottrackheader.enabled" = true;

    # Restore previous session
    "browser.startup.page" = 3;

    # Disable internal password manager
    "signon.rememberSignons" = false;

    # Dark theme
    "devtools.theme" =
      if config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme then
        "dark"
      else
        "light";
    "extensions.activeThemeID" = concatStrings [
      "firefox-compact-"
      (if config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme then
        "dark"
      else
        "light")
      "@mozilla.org"
    ];
  };

in {
  config = mkIf config.custom.x11.enable {
    programs.firefox = {
      enable = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # authy
        browserpass
        canvasblocker
        clearurls
        darkreader
        decentraleyes
        # grammarly
        https-everywhere
        multi-account-containers
        temporary-containers
        terms-of-service-didnt-read
        ublock-origin
        umatrix
        tridactyl
      ];

      profiles = {
        private = {
          id = 1;
          isDefault = true;

          settings = sharedSettings;
        };

        work = {
          id = 2;
          isDefault = false;

          settings = sharedSettings;
        };

        secret = {
          id = 0;
          path = "3ugol2lb.default";
          isDefault = false;

          settings = sharedSettings;
        };
      };

      # A lot of the config was taken from https://github.com/tridactyl/tridactyl/blob/master/.tridactylrc
      tridactyl = {
        enable = true;

        commands = {
          # Stupid workaround to let hint -; be used with composite which steals semi-colons
          hint_focus = "hint -;";
          # Inject Google Translate
          # This (clearly) is remotely hosted code. Google will be sent the whole
          # contents of the page you are on if you run `:translate`
          # From https://github.com/jeremiahlee/page-translator
          translate = ''
            js let googleTranslateCallback = document.createElement('script'); googleTranslateCallback.innerHTML = "function googleTranslateElementInit(){ new google.translate.TranslateElement(); }"; document.body.insertBefore(googleTranslateCallback, document.body.firstChild); let googleTranslateScript = document.createElement('script'); googleTranslateScript.charset="UTF-8"; googleTranslateScript.src = "https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit&tl=&sl=&hl="; document.body.insertBefore(googleTranslateScript, document.body.firstChild);'';
        };

        autoCommands = {
          # Redirects
          "^http(s?)://www.amazon." = {
            DocStart = [ ''js tri.excmds.urlmodify("-t", "www", "smile")'' ];
          };
        };

        bindings = {
          # Open right click menu on links
          ";C" =
            "composite hint_focus; !s ${pkgs.xdotool}/bin/xdotool key Menu";
          # Handy multiwindow/multitasking binds
          gd = "tabdetach";
          gD = "composite tabduplicate; tabdetach";
          # Make yy use canonical / short links on the 5 websites that support them
          yy = "clipboard yankcanon";
          # Use vimium prev/next tab bindings
          J = "tabprev";
          K = "tabnext";
          # Comment toggler for Reddit, Hacker News and Lobste.rs
          ";c" = ''
            hint -Jc [class*="expand"],[class="togg"],[class="comment_folder"]'';
        };

        urlBindings = {
          "github.com" = {
            # Pull request checkout command to clipboard (only works if you're a collaborator or above)
            ",yp" = ''
              composite js document.getElementById("clone-help-step-1").textContent.replace("git checkout -b", "git checkout -B").replace("git pull ", "git fetch ") + "git reset --hard " + document.getElementById("clone-help-step-1").textContent.split(" ")[3].replace("-","/") | yank'';
            # Yank git URI
            ",yr" = ''
              composite js document.location.href.replace(/https?:\/\//,"git@").replace("/",":").replace(/$/,".git") | clipboard yank'';
            # Clone repo
            ",g" = ''
              js const uri = document.location.href.replace(/https?:\/\//,"git@").replace("/",":").replace(/$/,".git"); const namespace = uri.replace(/^git@git(?:hub|lab).com:/, "").replace(/\/.*?\.git$/, ""); tri.native.run(`mkdir -p ~/.ghq/''${namespace}; cd ~/.ghq/''${namespace}; git clone ''${uri}; cd \"$(basename \"''${uri}\" .git)\"`)'';
          };

          "gitlab.com" = {
            # Yank git URI
            ",y" = ''
              composite js document.location.href.replace(/https?:\/\//,"git@").replace("/",":").replace(/$/,".git") | clipboard yank'';
            # Clone repo
            ",g" = ''
              js const uri = document.location.href.replace(/https?:\/\//,"git@").replace("/",":").replace(/$/,".git"); const namespace = uri.replace(/^git@git(?:hub|lab).com:/, "").replace(/\/.*?\.git$/, ""); tri.native.run(`mkdir -p ~/.ghq/''${namespace}; cd ~/.ghq/''${namespace}; git clone ''${uri}; cd \"$(basename \"''${uri}\" .git)\"`)'';
          };

          "www.google.com" = {
            # Only hint search results
            f = "hint -Jc .rc > .r > a";
            F = "hint -Jbc .rc > .r > a";
          };

          "^https://duckduckgo.com" = {
            # Only hint search results
            f = "hint -Jc [class=result__a]";
            F = "hint -Jbc [class=result__a]";
          };
        };

        searchUrls = {
          # Nix
          # Adding `&show=%s` would automagically open matching entries, but tridactyl only expands the first %s, so it would break the search
          np =
            "https://search.nixos.org/packages?channel=20.09&sort=relevance&query=%s";
          no =
            "https://search.nixos.org/options?channel=20.09&sort=relevance&query=%s";
          nup =
            "https://search.nixos.org/packages?channel=unstable&sort=relevance&query=%s";
          nuo =
            "https://search.nixos.org/options?channel=unstable&sort=relevance&query=%s";

          # Haskell
          hh = "https://hoogle.haskell.org/?hoogle=%s";
          hp = "https://hackage.haskell.org/packages/search?terms=%s";

          # Forges
          gh = "https://github.com/search?q=%s";
          ghp = "https://github.com/%s";
          gl = "https://gitlab.com/search?q=%s";
          glp = "https://gitlab.com/%s";

          # JavaScript
          js = "https://developer.mozilla.org/en-US/search?q=%s";
          jsp = "https://www.npmjs.com/search?q=%s";
          jfp = "https://gcanti.github.io/fp-ts/modules/%s.ts.html";

          # Shopping
          az =
            "https://smile.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=%s";

          # Other
          g = "https://www.google.com/search?q=%s";
          gs = "https://scholar.google.com/scholar?q=%s";
          w = "https://en.wikipedia.org/wiki/Special:Search/%s";
          yt = "https://www.youtube.com/results?search_query=%s";
          sp =
            "https://startpage.com/do/search?language=english&cat=web&query=%s";
          osm = "https://www.openstreetmap.org/search?query=%s";
        };

        theme = "dark";

        enableSmoothScroll = true;

        hint = {
          filterMode = "vimperator-reflow";
          names = "numeric";
          delay = 100;
        };
      };
    };
    programs.browserpass.browsers = [ "firefox" ];

    home.sessionVariables = { BROWSER = "firefox"; };
    xdg.mimeApps.defaultApplications = let
      listToAttrs' = pairs:
        with lib;
        listToAttrs (concatMap
          ({ names, value }: map (name: nameValuePair name value) names) pairs);
    in listToAttrs' [
      {
        names = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/vnd.mozilla.xul+xml"
        ];
        value = "firefox.desktop";
      }
      {
        names = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
        value = "firefox-auto.desktop";
      }
    ];

    home.packages = let
      escapeDesktopArg = arg:
        replaceStrings [ ''"'' ] [ ''"\""'' ] (toString arg);
      mkExec = with lib;
        { app ? null, profile ? null, ... }: ''
          firefox ${
            optionalString (profile != null)
            ''-P "${escapeDesktopArg profile}"''
          } ${
            optionalString (app != null) ''--ssb="${escapeDesktopArg app}"''
          } %U
        '';
      mkFirefoxDesktopItem = attrs:
        pkgs.makeDesktopItem ({
          icon = "firefox";
        } // (removeAttrs attrs [ "app" "profile" ]) // {
          exec = mkExec attrs;
        });
      autoFirefox = pkgs.makeDesktopItem {
        name = "firefox-auto";
        desktopName = "Firefox (automatic profile)";
        icon = "firefox";
        mimeType = "x-scheme-handler/http;x-scheme-handler/https";
        genericName = "Web Browser";
        categories = "Application;Network;WebBrowser";
        exec = let
          mkKeyword = s: [ "${s}." "*.${s}.*" "*/${s}/*" ];
          profiles = {
            private = [ ];
            work = lib.flatten (builtins.map mkKeyword [ "fitnesspilot" ]) ++ [
              "*.asana.com/*"
              "cloud.google.com/*"
              "meet.google.com/*"
              "*.slack.com/*"
              "*.nuget.org/*"
              "*.microsoft.com/*"
            ];
            secret = [ ];
          };
          attrsToList = v:
            lib.flatten
            (lib.mapAttrsToList (k: builtins.map (lib.nameValuePair k)) v);
          concatMapAttrsToString = sep: f: v:
            lib.concatMapStringsSep sep ({ name, value }: f name value)
            (attrsToList v);
          script = pkgs.writeScript "firefox-auto" ''
            url=$1
            profile=
            matchUrl=''${url#"http://"}
            matchUrl=''${matchUrl#"https://"}
            case "''${matchUrl}" in
              ${concatMapAttrsToString "\n  " (k: v: "${v}) ${k} ;;") profiles}
              *) profile=$(echo -e "private\nwork\nsecret" | ${pkgs.rofi}/bin/rofi -dmenu) ;;
            esac
            if [[ $profile == "" ]] ; then
              firefox "$url"
            else
              firefox -P "$profile" "$url"
            fi
          '';
        in "${script} %U";
      };
    in (with pkgs;
      [
        ((tor-browser-bundle-bin.override {
          pulseaudioSupport = true;
        }).overrideAttrs (old: { meta = old.meta // { broken = false; }; }))
      ]) ++ [
        autoFirefox
        (mkFirefoxDesktopItem {
          name = "youtube-music";
          desktopName = "YouTube Music";
          app = "https://music.youtube.com";
        })
      ] ++ mapAttrsToList (k: v:
        mkFirefoxDesktopItem {
          name = "firefox-profile-${k}";
          desktopName = "Firefox (${v.name})";
          profile = v.name;
          mimeType =
            "text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
          genericName = "Web Browser";
          categories = "Application;Network;WebBrowser";
        }) (filterAttrs (k: v: !v.isDefault) config.programs.firefox.profiles);
  };
}
