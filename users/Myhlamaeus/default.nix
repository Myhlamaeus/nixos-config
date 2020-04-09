{ config, pkgs, ... }:

{
  security.pam.enableEcryptfs = true;

  users.users.Myhlamaeus = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" "docker" ];
  };

  home-manager.users.Myhlamaeus = import ./home config.nixpkgs.overlays config.nixpkgs.config.packageOverrides;
}
