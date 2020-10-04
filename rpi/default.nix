{ config, pkgs, lib, ... }:

with builtins;

let
  matrixServerName = "matrix.${ config.networking.domain }";

in
{
  imports = [
    ./backups.nix
    ./grocy.nix
    ./matrix.nix
    ./webdav.nix
  ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  custom = {
    # backups.enable = true;
    matrix-synapse.enable = true;
    webdav.enable = true;
    grocy.enable = true;
  };

  environment.systemPackages = with pkgs; [
    rxvt_unicode.terminfo
  ];

  i18n.defaultLocale = "en_GB.UTF-8";

  services.openssh = {
    enable = true;

    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = [(readFile "./key")];
  };

  security.acme = {
    email = "dreyer.maltem+dev@gmail.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      ${ config.networking.domain } = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      3478
      5349
    ];
    allowedUDPPorts = [
      3478
      5349
    ];
    allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];
  };

  users.users.Myhlamaeus = {
    openssh.authorizedKeys.keyFiles = [ ./key ];
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" "docker" ];
  };

  networking.wireless.enable = false;
}
