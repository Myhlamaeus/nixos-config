{ pkgs, ... }:

{
  # Doesn't work because bin/ is a symlink
  # custom.editors.env.bin.packages = with pkgs.nodePackages; [ eslint prettier typescript-language-server ];
  home.packages = with pkgs.nodePackages; [
    pkgs.nodejs
    eslint
    prettier
    typescript-language-server
  ];
  custom.editors.emacs.setup = ''
    (setenv "PATH" (concat "/home/Myhlamaeus/.local/share/npm/bin:" (getenv "PATH")))
    (add-to-list 'exec-path "/home/Myhlamaeus/.local/share/npm/bin" t)
  '';
}
