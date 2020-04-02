{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    configure = {
      customRC = ''
        :inoremap fd <Esc>
      '';
      packages.nix = with pkgs.vimPlugins; {
        # loaded on launch
        start = [ vim-nix ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [];
      };
    };
  };
}
