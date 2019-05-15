{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
      url = "https://github.com/nix-community/NUR/archive/44626b757f6d3fd8c87239953d3d670e75bab3b8.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "1gfgl7qimp76q4z0nv55vv57yfs4kscdr329np701k0xnhncwvrk";
    };
  };
}
