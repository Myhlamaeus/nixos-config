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
      msmtp = { enable = true; };
      passwordCommand = "${pkgs.coreutils}/bin/cat ~/.config/email/private";
      gpg = { key = "7FCB362E2D975AD2A45A682CAD1390B6FE33C758"; };
    };
  };
  programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
    hooks.postNew = ''
      notmuch tag +calendar -- tag:new and mimetype:text/calendar
      notmuch tag +notification -- tag:new and from:notifications@

      notmuch tag +unread +inbox -new -- tag:new
    '';
    new.tags = [ "new" ];
  };
  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    postExec = "${pkgs.notmuch}/bin/notmuch new";
  };
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
