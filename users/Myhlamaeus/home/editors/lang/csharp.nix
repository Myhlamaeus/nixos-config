{ pkgs, ... }:

with pkgs;
let
  pkgs-unstable = (import <nixpkgs-unstable> { config = { allowUnfree = true; }; });
  dotnet-combined = with pkgs-unstable.dotnetCorePackages; combinePackages [ sdk_3_1 sdk_2_1 ];
  dotnetRoot = "${dotnet-combined}/bin";
  dotnetSdk = "${dotnet-combined}/sdk";
  dotnetBinary = "${dotnetRoot}/dotnet";
in
{
  custom.editors = {
    env = {
      bin.packages = [
        dotnet-combined
        omnisharp-roslyn
      ];

      vars = {
        DOTNET_ROOT = dotnetRoot;
      };
    };

    emacs.setup = ''
      (let (
        (dotnet-sdk (concat "${dotnetSdk}/" (string-trim-right (shell-command-to-string "${dotnetBinary} --version"))))
        )
        (setenv "MSBuildSdksPath" (concat dotnet-sdk "/Sdks"))
        (setenv "MSBUILD_EXE_PATH" (concat dotnet-sdk "/MSBuild.dll"))
      )
    '';
  };

  home.file.".omnisharp/omnisharp.json" = {
    text = builtins.toJSON {
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true;
      };
    };
  };
}
