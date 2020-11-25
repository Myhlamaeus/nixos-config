{ pkgs, ... }:

{
  accounts.email.accounts = {
    home = {
      primary = true;
      imap = {
        host = "localhost";
        port = 1143;
        tls.enable = false;
      };
      imapnotify = {
        enable = true;
        onNotifyPost = {
          mail = "\${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
        };
      };
      smtp = {
        host = "localhost";
        port = 1025;
        tls.enable = false;
      };
      address = "me@maublew.name";
      userName = "maublew";
      realName = "Maurice B. Lewis";
      notmuch.enable = true;
      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
      };
      msmtp = {
        enable = true;
        extraConfig = { auth = "plain"; };
      };
      passwordCommand = "${pkgs.coreutils}/bin/cat ~/.config/email/home";
    };
  };
  programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
    hooks.postNew = ''
      notmuch tag +calendar -- tag:new and mimetype:text/calendar
      notmuch tag +notification -- tag:new and from:notifications@

      notmuch tag +important -- Importance:high
      notmuch tag +unimportant -- Importance:low
      notmuch tag -new -- tag:sent
      notmuch tag +unread +inbox -new -- tag:new
    '';
    new.tags = [ "new" ];
    extraConfig = { index = { "header.Importance" = "Importance"; }; };
  };
  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    postExec = "${pkgs.notmuch}/bin/notmuch new";
  };
  services.imapnotify.enable = true;
  systemd.user.services.mbsync.Service.Environment =
    [ "NOTMUCH_CONFIG=/home/Myhlamaeus/.config/notmuch/notmuchrc" ];
  programs.msmtp.enable = true;

  home.file.".mailcap" = {
    text = ''
      text/html;  ${pkgs.w3m}/bin/w3m -dump -o document_charset=%{charset} '%s'; nametemplate=%s.html; copiousoutput
    '';
  };

  home.file.".mailrc" = {
    text = ''
      set sendmail="msmtp"
    '';
  };

  systemd.user.services.emacs.Service.Environment =
    [ "NOTMUCH_CONFIG=/home/Myhlamaeus/.config/notmuch/notmuchrc" ];
}
