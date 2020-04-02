{ pkgs, ... }:

{
  accounts.email.accounts = {
    home = {
      primary = true;
      flavor = "gmail.com";
      address = "dreyer.maltem@gmail.com";
      userName = "dreyer.maltem@gmail.com";
      realName = "Maurice B. Lewis";
      notmuch.enable = true;
      mbsync = {
        enable = true;
        create = "both";
        patterns = [
          "*"
          "![Gmail]*"
          "[Gmail]/Sent Mail"
          "[Gmail]/Starred"
          "[Gmail]/All Mail"
        ];
      };
      msmtp = {
        enable = true;
      };
      passwordCommand = "${pkgs.coreutils}/bin/cat ~/.config/email/private";
      gpg = {
        key = "7FCB362E2D975AD2A45A682CAD1390B6FE33C758";
      };
    };

    upsquared = {
      flavor = "gmail.com";
      address = "md@upsquared.com";
      userName = "md@upsquared.com";
      realName = "Maurice Dreyer";
      notmuch.enable = true;
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
      };
      msmtp = {
        enable = true;
      };
      passwordCommand = "${pkgs.coreutils}/bin/cat ~/.config/email/work";
    };
  };
  programs.alot = {
    enable = true;
  };
  programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
    hooks.postNew = ''
      notmuch tag +calendar -- tag:new and mimetype:text/calendar

      notmuch tag +upsquared -- tag:new and \( to:@upsquared.com or from:@upsquared.com or from:@digital-spring.de \)
      notmuch tag -upsquared -- tag:new and tag:calendar and subject:"Play Divinity"
      notmuch tag +fitnesspilot -- tag:new and \( from:@fitnesspilot.com or fitnesspilot \)
      notmuch tag +veepee -- tag:new and \( from:@kontakt.veepee.de or from:@venteprivee.com or from:@vente-exclusive.com or from:@vente-privee.com or from:@veepee.com \)
      notmuch tag +debatoo -- tag:new and from:@debatoo.com
      notmuch tag +test -inbox -- tag:new and tag:upsquared and \( from:@fitnesspilot.com or from:@kontakt.veepee.de or from:@venteprivee.com \)

      notmuch tag +unread +inbox -new -- tag:new
    '';
    new.tags = [ "new" ];
  };
  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    postExec = "${pkgs.notmuch}/bin/notmuch new";
  };
  systemd.user.services.mbsync.Service.Environment = [ "NOTMUCH_CONFIG=/home/Myhlamaeus/.config/notmuch/notmuchrc" ];
  programs.msmtp.enable = true;

  home.file.".mailcap" = {
    text = ''
      text/html;  ${pkgs.w3m}/bin/w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput
    '';
  };
}
