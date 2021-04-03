{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-20.09";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.pre-commit-hooks = {
    url =
      # "github:Myhlamaeus/pre-commit-hooks.nix/feat/flake";
      "github:Myhlamaeus/pre-commit-hooks.nix/8d48a4cd434a6a6cc8f2603b50d2c0b2981a7c55";
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

  inputs.omnisharp-roslyn = {
    url = "github:OmniSharp/omnisharp-roslyn/master";
    flake = false;
  };

  inputs.obelisk-source = {
    url = "github:obsidiansystems/obelisk/master";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, pre-commit-hooks, nur
    , nixpkgs-unstable, cheatsheets, felschr-nixos, funkwhale, gitignore
    , omnisharp-roslyn, obelisk-source }:
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

              # dunno how to set allowUnfree with nixpkgs-unstable.legacyPackages.x86_64-linux
              (self: super:
                let
                  unstable = import nixpkgs-unstable.outPath {
                    inherit (self) system;
                    config = { allowUnfree = true; };
                  };
                in {
                  inherit (unstable)
                    dwarf-fortress-packages emacs notmuch openhantek openmw
                    zsh-completions;
                  inherit (unstable.gitAndTools) git-bug;
                  inherit gitignore;

                  cheatPackages = { community = cheatsheets; };

                  omnisharp-roslyn = super.omnisharp-roslyn.overrideAttrs
                    (oldAttrs: rec {
                      version = omnisharp-roslyn.rev;
                      versionSuffix = "-git";
                      src = omnisharp-roslyn;
                    });

                  teensy-loader-cli = let
                    teensy-udev-rules = builtins.fetchurl {
                      url = "https://www.pjrc.com/teensy/49-teensy.rules";
                      sha256 =
                        "052rgk3q9pnxrrxx98x6yrhbxvhjp1z5mn4vpkwgni7jrrnvn5vw";
                    };
                  in super.teensy-loader-cli.overrideAttrs (attrs: rec {
                    postInstall = (attrs.postInstall or "") + ''
                      mkdir -p $out/lib/udev/rules.d
                      cp ${teensy-udev-rules} $out/lib/udev/rules.d/49-teensy.rules
                    '';
                  });

                  proton-ge-custom = pkgs.stdenv.mkDerivation rec {
                    pname = "proton-ge-custom";
                    version = "5.9-GE-8-ST";
                    src = builtins.fetchurl {
                      name = "${pname}-${version}-source";
                      url =
                        "https://github.com/GloriousEggroll/${pname}/releases/download/${version}/Proton-${version}.tar.gz";
                      sha256 =
                        "129ws0hq2l6bb69y2afgcb98ns68bn0z8ks44nvz9gf53a8nxzdd";
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
        pre-commit-check = pre-commit-hooks.defaultPackage.${system} {
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
