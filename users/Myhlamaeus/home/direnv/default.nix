{ ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    stdlib = ''
      ${builtins.readFile ./nix.sh}
    '';
  };
}
