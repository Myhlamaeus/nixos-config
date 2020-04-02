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
  nixpkgs.overlays = [
    (self: super: {
      omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
          version = "1.34.9";
          src = fetchurl {
            url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-mono.tar.gz";
            sha256 = "1b5jzc7dj9hhddrr73hhpq95h8vabkd6xac1bwq05lb24m0jsrp9";
          };
      });
    })
  ];

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
