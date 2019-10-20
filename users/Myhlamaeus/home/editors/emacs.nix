{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
  };

  services.emacs.enable = true;

  # Not yet in stable
  # systemd.user.sessionVariables = {
  home.sessionVariables = {
    VISUAL = "emacs";
  };
}
