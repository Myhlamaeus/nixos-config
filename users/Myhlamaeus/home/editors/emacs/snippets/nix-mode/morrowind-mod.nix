# -*- mode: snippet -*-
#name : MorrowindMod
#key : MorrowindMod
#contributor :
# --
{ mkDerivation, fetchurl, dos2unix, lib$6
}:

# https://modding-openmw.com/mods/${1:`(file-name-base (directory-file-name (file-name-directory (buffer-file-name))))`}/
mkDerivation {
  pname = "$1";
  version = "$2";
  src = builtins.path { path = ../../../data + "/$4.${3:7z}"; name = "$1-$2.$3"; };
  outputs = [ "out" "doc" ];
  installPhase = ''
    mkdir -p {$out,$doc}

    $7cp -r "Data Files"/* $out/

    ${dos2unix}/bin/dos2unix -n CorrectUVRocks_Eng.txt $doc/README.txt
    cp -r Images $doc/imgs
  '';
}
