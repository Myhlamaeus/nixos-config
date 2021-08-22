let
  target = "/persist";
  link = f: t: "L ${f} - - - - ${t}";
  root = path: link "/${path}" "${target}/${path}";
  home = path: root "home/Myhlamaeus/${path}";
  xdgConfig = path: home ".config/${path}";
  xdgData = path: home ".local/share/${path}";
  varLib = path: root "var/lib/${path}";

in {
  environment.etc = {
    nixos.source = "${target}/etc/nixos";
    # "NetworkManager/system-connections".source = "${target}/etc/NetworkManager/system-connections";
    adjtime.source = "${target}/etc/adjtime";
    NIXOS.source = "${target}/etc/NIXOS";
    machine-id.source = "${target}/etc/machine-id";
  };

  systemd.tmpfiles.rules = (map varLib [
    "flatpak"
    # "NetworkManager/secret_key"
    # "NetworkManager/seen-bssids"
    # "NetworkManager/timestamps"
  ])

  # per user (move out at some point)
    ++ [
      (link "/home/Myhlamaeus/.config/spacemacs"
        "/etc/nixos/users/Myhlamaeus/spacemacs")
      (link "/home/Myhlamaeus/org"
        "/home/Myhlamaeus/media/keybase/private/myhlamaeus/org")
    ] ++ (map home [
      ".aws"
      ".elfeed"
      ".gnupg"
      ".local/state/protonmail"
      ".mozilla/firefox"
      ".password-store"
      ".ssh"
      ".var/app/org.telegram.desktop"
      ".wine-ebook-drm"
      ".zotero"
      "Desktop"
      "Documents"
      "Downloads"
      "calibre-ebook-drm"
      "org.bak"
    ]) ++ (map xdgConfig [
      "Element"
      "calibre"
      "chromium"
      "emacs"
      "email"
      "keybase"
      "protonmail"
    ]) ++ (map xdgData [
      "Steam"
      "direnv"
      "etesync-dav"
      "flatpak"
      "keybase"
      "tor-browser"
      "zsh"
    ]);

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # zsh keeps on replacing the .zsh_history ln with a new file
  home-manager.users.Myhlamaeus.programs.zsh.history.path =
    "${target}/home/Myhlamaeus/.local/share/zsh/history";
}
