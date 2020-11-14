{ pkgs, ... }:

with pkgs;

{
  home.file.".omnisharp/omnisharp.json" = {
    text = builtins.toJSON {
      RoslynExtensionsOptions = { EnableAnalyzersSupport = true; };
    };
  };
}
