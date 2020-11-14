{ pkgs, ... }:

{
  # Doesn't work because bin/ is a symlink
  # custom.editors.env.bin.packages = with pkgs.nodePackages; [ eslint prettier typescript-language-server ];
  home.packages = with pkgs.nodePackages; [
    eslint
    prettier
    typescript-language-server
  ];
}
