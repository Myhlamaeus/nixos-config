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
  };
  programs.alot = {
    enable = true;
  };
  programs.notmuch = {
    enable = true;
    maildir.synchronizeFlags = true;
  };
  programs.mbsync.enable = true;
  services.mbsync = {
    enable = true;
    postExec = "${pkgs.notmuch}/bin/notmuch --config /home/Myhlamaeus/.config/notmuch/notmuchrc new";
  };
  programs.msmtp.enable = true;
}
