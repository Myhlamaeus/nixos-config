{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  security.pam.enableEcryptfs = true;

  users.users.Myhlamaeus = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" ];
  };
}
