{ lib, stdenv, fetchurl, makeWrapper, curl, icu60, openssl, zlib }:

let
  arch =
    with stdenv.hostPlatform;
    if isx86_64 then "AMDx64"
    else if isAarch32 then "ARM32"
    else if isAarch64 then "ARM64"
    else abort "Unsupported architecture";
in stdenv.mkDerivation rec {
  pname = "jackett";
  version = "0.11.817";

  src = fetchurl {
    url = "https://github.com/Jackett/Jackett/releases/download/v${version}/Jackett.Binaries.Linux${arch}.tar.gz";
    sha256 = with stdenv.hostPlatform;
             if isAarch64 then "0bnz3rwljiabzm6vhs4dis3556h9p0l5ynj98a1am1khxgkqk81h"
             else if isAarch32 then "0jllrzkk1zxl0h365y2d778y7vni8lcg2bj7qb6i0ajxmy25gvib"
             else "1bln9fplw5zhyahdnqqby2as43wvmhch3hb1ik1xngh38l75jdyp";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,opt/${pname}-${version}}
    cp -r * $out/opt/${pname}-${version}

    makeWrapper "$out/opt/${pname}-${version}/jackett" $out/bin/Jackett \
      --prefix LD_LIBRARY_PATH ':' "${curl.out}/lib:${icu60.out}/lib:${openssl.out}/lib:${zlib.out}/lib"
  '';

  preFixup = let
    libPath = lib.makeLibraryPath [
      stdenv.cc.cc.lib  # libstdc++.so.6
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/opt/${pname}-${version}/jackett
  '';

  meta = with stdenv.lib; {
    description = "API Support for your favorite torrent trackers.";
    homepage = https://github.com/Jackett/Jackett/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ edwtjo nyanloutre ];
    platforms = platforms.linux;
  };
}
