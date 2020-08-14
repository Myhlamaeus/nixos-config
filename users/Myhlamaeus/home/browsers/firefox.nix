{ config, pkgs, lib, ... }:

with lib;

let
  sharedSettings = {
    # A result of the Tor Uplift effort, this preference isolates all browser identifier sources (e.g. cookies) to the first party domain, with the goal of preventing tracking across different domains. (Don't do this if you are using the Firefox Addon "Cookie AutoDelete" with Firefox v58 or below.)
    "privacy.firstparty.isolate" = true;
    # A result of the Tor Uplift effort, this preference makes Firefox more resistant to browser fingerprinting.
    "privacy.resistFingerprinting" = true;
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

    "devtools.theme" = if config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme
      then "dark"
      else "light";
    "extensions.activeThemeID" = concatStrings
      [ "firefox-compact-"
        (if config.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme then "dark" else "light")
        "@mozilla.org"
      ];
  };

in
{
  config = mkIf config.custom.x11.enable {
    programs.firefox = {
      enable = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        browserpass
        darkreader
        vimium
        ublock-origin
        https-everywhere
        decentraleyes
        # clearurls
        # grammarly
        # authy
        # terms-of-service-didnt-read
        temporary-containers
        multi-account-containers
        umatrix
        # canvasblocker
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
    };
    programs.browserpass.browsers = [ "firefox" ];

    home.sessionVariables = {
      BROWSER = "firefox";
    };

    home.packages = with pkgs; [
      (tor-browser-bundle-bin.override { pulseaudioSupport = true; })
    ];
  };
}
