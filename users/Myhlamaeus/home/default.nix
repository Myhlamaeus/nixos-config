{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  users.users.Myhlamaeus = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" ];
  };
}
