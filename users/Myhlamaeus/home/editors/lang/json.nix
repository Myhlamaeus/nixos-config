{ pkgs, ... }:

{
  # Doesn't work because bin/ is a symlink
  # custom.editors.env.bin.packages = with pkgs.nodePackages; [ prettier vscode-json-languageserver ];
  home.packages = with pkgs.nodePackages; [
    prettier
    # Not yet in nixpkgs
    # vscode-json-languageserver
  ];
}
