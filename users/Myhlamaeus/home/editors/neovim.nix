{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [{ plugin = vim-nix; }];
    extraConfig = ''
      :inoremap fd <Esc>
    '';
  };
}
