{ config, pkgs, ... }:

{
  # Enable sound.
  sound.enable = true;
  # services.jack = {
  #   jackd.enable = true;
  #   # support ALSA only programs via ALSA JACK PCM plugin
  #   alsa.enable = false;
  #   # support ALSA only programs via loopback device (supports programs like Steam)
  #   loopback = {
  #     enable = true;
  #     # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
  #     #dmixConfig = ''
  #     #  period_size 2048
  #     #'';
  #   };
  # };
  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    # package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
  };
  home-manager.users.Myhlamaeus.xdg.configFile."pulse/client.conf".text = ''
    daemon-binary=/var/run/current-system/sw/bin/pulseaudio
  '';
  home-manager.users.Myhlamaeus.home.packages = with pkgs; [
    pavucontrol
    qjackctl
    jack_rack
    ladspaPlugins
    audacity
  ];
}
