{ config, pkgs, ... }:

{
  security.pam.enableEcryptfs = true;

  users.users.Myhlamaeus = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" "docker" "podman" "audio" "jackaudio" ];
    passwordFile = "/etc/nixos/secrets/Myhlamaeus-password";
  };

  home-manager.users.Myhlamaeus = import ./home;
}
