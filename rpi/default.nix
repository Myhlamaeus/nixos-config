{ config, pkgs, lib, ... }:

with builtins;

let matrixServerName = "matrix.${config.networking.domain}";

in {
  imports = [
    ./backups.nix
    ./grocy.nix
    ./home-assistant.nix
    ./matrix.nix
    ./webdav.nix
    ./funkwhale.nix
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
    grocy.enable = true;
    home-assistant.enable = true;
    matrix-synapse.enable = true;
    webdav.enable = true;
    funkwhale.enable = true;
  };

  local.services.deconz = {
    enable = true;
    httpPort = 8080;
    wsPort = 1443;
  };

  environment.systemPackages = with pkgs; [ git rxvt_unicode.terminfo ];

  i18n.defaultLocale = "en_GB.UTF-8";

  services.openssh = {
    enable = true;

    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = [ (readFile "./key") ];
  };

  security.acme = {
    email = "dreyer.maltem+dev@gmail.com";
    acceptTerms = true;
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      ${config.networking.domain} = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 3478 5349 ];
    allowedUDPPorts = [ 3478 5349 ];
    allowedUDPPortRanges = [{
      from = 49152;
      to = 65535;
    }];
  };

  users.users.Myhlamaeus = {
    openssh.authorizedKeys.keyFiles = [ ./key ];
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/Myhlamaeus";
    extraGroups = [ "wheel" "docker" ];
  };

  networking.wireless.enable = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.03"; # Did you read the comment?
}
