{ pkgs, ... }:

let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
{
  custom.editors.env.bin.packages = [
    (all-hies.unstable.selection {
      selector = p: { inherit (p) ghc864 ghc865 ghc881 ghc882; };
    })
  ];
}
