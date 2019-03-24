{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [ vim-nix ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
      };
    };
  };

  # Not yet in stable
  # systemd.user.sessionVariables = {
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
