{ lib, stdenv, dpkg, fetchurl }:

let
  generic = { version, sha256, suffix ? "" }:
  stdenv.mkDerivation {
    pname = "unifi-controller";
    inherit version;

    src = fetchurl {
      url = "https://dl.ubnt.com/unifi/${version}${suffix}/unifi_sysvinit_all.deb";
      inherit sha256;
    };

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src ./
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cd ./usr/lib/unifi
      cp -ar dl lib webapps $out

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "http://www.ubnt.com/";
      description = "Controller for Ubiquiti UniFi access points";
      license = licenses.unfree;
      platforms = platforms.unix;
      maintainers = with maintainers; [ erictapen globin patryk27 ];
    };
  };

in rec {
  # see https://community.ui.com/releases / https://www.ui.com/download/unifi

  unifiStable = generic {
    version = "6.1.71";
    sha256 = "1lvsq0xpfgwpbzs25khy7bnrhv8i1jgzi8ij75bsh65hfa3rplc2";
  };
}

