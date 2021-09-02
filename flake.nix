{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  # calibre is broken in stable
  inputs.nixpkgs-calibre.url =
    "github:NixOS/nixpkgs/ea7d4aa9b8225abd6147339f0d56675d6f1f0fd1";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixops.url = "github:NixOS/nixops/master";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-21.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.cheatsheets = {
    url = "github:cheat/cheatsheets/master";
    flake = false;
  };

  inputs.felschr-nixos = {
    url =
      "gitlab:FelschR/nixos-config/bfedaaae23620ca82e8491a5ed09130e2099fcac";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
    inputs.nur.follows = "nur";
    inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    inputs.obelisk.follows = "obelisk-source";
  };

  inputs.funkwhale = { url = "github:mmai/funkwhale-flake"; };

  inputs.gitignore = {
    url = "github:toptal/gitignore/master";
    flake = false;
  };

  inputs.obelisk-source = {
    url = "github:obsidiansystems/obelisk/master";
    flake = false;
  };

  inputs.Linux-Fake-Background-Webcam-source = {
    url = "github:fangfufu/Linux-Fake-Background-Webcam/master";
    flake = false;
  };

  outputs = { self, nixpkgs, nixpkgs-calibre, flake-utils, nixops, home-manager
    , pre-commit-hooks, nur, nixpkgs-unstable, cheatsheets, felschr-nixos
    , funkwhale, gitignore, obelisk-source, Linux-Fake-Background-Webcam-source
    }:
    rec {

      nixosModules.fontOverrides = import ./nixosModules/fontOverrides.nix;

      homeManagerModules.firefoxAutoProfile =
        import ./homeManagerModules/firefoxAutoProfile.nix;

      homeManagerModules.tridactyl = import ./homeManagerModules/tridactyl.nix;

      nixosConfigurations.home-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected

          ({ pkgs, ... }: {
            networking = {
              hostName = "home-desktop";
              domain = "maurice-dreyer.name";
            };

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;

            nix.registry.nixpkgs.flake = nixpkgs;

            nixpkgs.overlays = [
              nur.overlay

              (self: super: {
                nixopsUnstable = nixops.defaultPackage.x86_64-linux;
              })

              # dunno how to set allowUnfree with nixpkgs-unstable.legacyPackages.x86_64-linux
              (self: super:
                let
                  unstable = import nixpkgs-unstable.outPath {
                    inherit (self) system;
                    config = { allowUnfree = true; };
                  };
                  calibre = import nixpkgs-calibre.outPath {
                    inherit (self) system;
                    config = { allowUnfree = true; };
                  };
                in {
                  inherit (unstable)
                    dwarf-fortress-packages emacs notmuch openhantek openmw
                    tor-browser-bundle-bin zsh-completions steam;
                  inherit (calibre) calibre;
                  inherit (unstable.gitAndTools) git-bug;
                  inherit gitignore;

                  akvcam = self.linuxPackages.callPackage
                    ((nixpkgs-unstable) + "/pkgs/os-specific/linux/akvcam") {
                      qmake = self.qt5.qmake;
                    };

                  cheatPackages = { community = cheatsheets; };

                  teensy-loader-cli = let
                    teensy-udev-rules = builtins.fetchurl {
                      url = "https://www.pjrc.com/teensy/49-teensy.rules";
                      sha256 =
                        "1qbl1f40jc0dg3z1lag2bk2b0nv54n9z3bdpwmdz09m50a0nskbv";
                    };
                  in super.teensy-loader-cli.overrideAttrs (attrs: rec {
                    postInstall = (attrs.postInstall or "") + ''
                      mkdir -p $out/lib/udev/rules.d
                      cp ${teensy-udev-rules} $out/lib/udev/rules.d/49-teensy.rules
                    '';
                  });

                  Linux-Fake-Background-Webcam-bodypix =
                    pkgs.stdenv.mkDerivation {
                      pname = "Linux-Fake-Background-Webcam-bodypix";
                      version = "git";
                      src = Linux-Fake-Background-Webcam-source + "/bodypix";
                    };

                  Linux-Fake-Background-Webcam-fakecam =
                    pkgs.stdenv.mkDerivation {
                      pname = "Linux-Fake-Background-Webcam-fakecam";
                      version = "git";
                      src = Linux-Fake-Background-Webcam-source + "/fakecam";
                    };

                  proton-ge-custom = pkgs.stdenv.mkDerivation rec {
                    pname = "proton-ge-custom";
                    version = "6.1-GE-2";
                    src = builtins.fetchurl {
                      name = "${pname}-${version}-source";
                      url =
                        "https://github.com/GloriousEggroll/${pname}/releases/download/${version}/Proton-${version}.tar.gz";
                      sha256 =
                        "1yrdw2p29vb5gqk84cyynz6z9qahiisg037r2cliclivjf17x45r";
                    };
                    unpackCmd = ''
                      mkdir out
                      tar -xzf $curSrc -C out
                    '';
                    installPhase = ''
                      cp -r Proton-${pkgs.lib.escapeShellArg version} $out
                    '';
                  };

                  obelisk =
                    (import obelisk-source { inherit (self) system; }).command;
                })
            ];
          })

          {
            imports = [
              # Something about this broke in 20.09
              # "${ nixpkgs.outPath }/nixos/modules/profiles/hardened.nix"
              "${home-manager}/nixos"
              nixosModules.fontOverrides
              ./system/hardware-configurations/home-desktop.nix
              ./system
              ./users
            ];

            home-manager.users.Myhlamaeus = {
              imports = [
                felschr-nixos.homeManagerModules.git
                homeManagerModules.firefoxAutoProfile
                homeManagerModules.tridactyl
              ];
            };
          }
        ];
      };

      nixosConfigurations.rpi = nixpkgs-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixpkgs.nixosModules.notDetected

          funkwhale.nixosModule

          ({ pkgs, ... }: {
            networking = {
              hostName = "rpi";
              domain = "maurice-dreyer.name";
            };

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision =
              nixpkgs-unstable.lib.mkIf (self ? rev) self.rev;

            nix.registry.nixpkgs.flake = nixpkgs-unstable;
          })

          {
            nixpkgs.overlays =
              [ felschr-nixos.overlays.deconz funkwhale.overlay ];

            nixpkgs.config.allowUnfree = true;

            imports = [
              ./rpi/hardware-configuration.nix
              felschr-nixos.nixosModules.deconz
              ./rpi
            ];
          }
        ];
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = { nixfmt.enable = true; };
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (ghc.withPackages
              (ps: with ps; [ xmonad xmonad-contrib containers ]))
            haskellPackages.haskell-language-server
          ];
          inherit (pre-commit-check) shellHook;
        };
      });
}
