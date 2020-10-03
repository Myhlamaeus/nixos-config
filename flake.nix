{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-20.03";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-20.03";
    flake = false;
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs-channels/nixos-unstable";

  inputs.cheatsheets = {
    url = "github:cheat/cheatsheets/master";
    flake = false;
  };

  inputs.felschr-nixos = {
    url = "gitlab:FelschR/nixos-config/main";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
    inputs.nur.follows = "nur";
  };

  inputs.gitignore = {
    url = "github:toptal/gitignore/master";
    flake = false;
  };

  inputs.omnisharp-roslyn = {
    url = "github:OmniSharp/omnisharp-roslyn/master";
    flake = false;
  };

  inputs.pass-git-helper = {
    url = "github:languitar/pass-git-helper/master";
    flake = false;
  };

  outputs = { self, nixpkgs, home-manager, nur, nixpkgs-unstable, cheatsheets, felschr-nixos, gitignore, omnisharp-roslyn, pass-git-helper }: {

    nixosConfigurations.home-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixpkgs.nixosModules.notDetected

          ({ pkgs, ... }: {
            networking.hostName = "home-desktop";

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            nix.registry.nixpkgs.flake = nixpkgs;

            nixpkgs.overlays = [
              nur.overlay

              # dunno how to set allowUnfree with nixpkgs-unstable.legacyPackages.x86_64-linux
              (self: super: let
                  unstable = import nixpkgs-unstable.outPath { system = "x86_64-linux"; config = { allowUnfree = true; }; };
                in
                {
                  inherit (unstable) dwarf-fortress-packages emacs notmuch openmw zsh-completions;
                  inherit (unstable.gitAndTools) git-bug;
                  inherit gitignore;

                  cheatPackages = {
                    community = cheatsheets;
                  };

                  omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs (oldAttrs: rec {
                    version = omnisharp-roslyn.rev;
                    versionSuffix = "-git";
                    src = omnisharp-roslyn;
                  });

                  teensy-loader-cli = let
                      teensy-udev-rules = builtins.fetchurl {
                        url = "https://www.pjrc.com/teensy/49-teensy.rules";
                        sha256 = "052rgk3q9pnxrrxx98x6yrhbxvhjp1z5mn4vpkwgni7jrrnvn5vw";
                      };
                    in
                    super.teensy-loader-cli.overrideAttrs (attrs: rec {
                      postInstall = (attrs.postInstall or "") + ''
                        mkdir -p $out/lib/udev/rules.d
                        cp ${teensy-udev-rules} $out/lib/udev/rules.d/49-teensy.rules
                      '';
                    });

                  pass-git-helper = super.python38Packages.buildPythonApplication {
                    pname = "pass-git-helper";
                    version = pass-git-helper.rev;
                    versionSuffix = "-git";

                    propagatedBuildInputs = with pkgs.python38Packages; [ pyxdg ];
                    checkInputs = with pkgs.python38Packages; [ coveralls pytest pytest-mock ];

                    src = pass-git-helper;

                    doCheck = false;
                  };

                  proton-ge-custom = pkgs.stdenv.mkDerivation rec {
                    pname = "proton-ge-custom";
                    version = "5.9-GE-6-ST";
                    src = builtins.fetchurl {
                      name = "${ pname }-${ version }-source";
                      url = "https://github.com/GloriousEggroll/${ pname }/releases/download/${ version }/Proton-${ version }.tar.gz";
                      sha256 = "1ryrkwivig5qnz57378x9jmz78nch71vhpxl73g366r7wlmx9m79";
                    };
                    unpackCmd = ''
                      mkdir out
                      tar -xzf $curSrc -C out
                    '';
                    installPhase = ''
                      cp -r Proton-${ pkgs.lib.escapeShellArg version } $out
                    '';
                  };
                }
              )
            ];
          })

          {
            imports = [
              "${ nixpkgs.outPath }/nixos/modules/profiles/hardened.nix"
              "${ home-manager }/nixos"
              ./system/hardware-configurations/home-desktop.nix
              ./system
              ./users
            ];

            home-manager.users.Myhlamaeus = {
              imports = [
                felschr-nixos.homeManagerModules.git
              ];
            };
          }
        ];
    };

    nixosConfigurations.rpi = nixpkgs-unstable.lib.nixosSystem {
      system = "aarch64-linux";
      modules =
        [
          nixpkgs.nixosModules.notDetected

          ({ pkgs, ... }: {
            networking = {
              hostName = "rpi";
              domain = "maurice-dreyer.name";
            };

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs-unstable.lib.mkIf (self ? rev) self.rev;

            nix.registry.nixpkgs.flake = nixpkgs-unstable;
          })

          {
            imports = [
              ./rpi/hardware-configuration.nix
              ./rpi
            ];
          }
        ];
    };

  };
}
