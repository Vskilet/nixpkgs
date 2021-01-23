{ lib, stdenv, fetchurl, makeDesktopItem, ffmpeg_3
, qmake, qttools, mkDerivation
, qtbase, qtdeclarative, qtlocation, qtquickcontrols2, qtwebchannel, qtwebengine
}:

mkDerivation rec {
  pname = "clipgrab";
  version = "3.9.5";

  src = fetchurl {
    sha256 = "1p8pqa5s70basdm2zpmahc54shsxrr0fr7chvv425n5a9sqba4dh";
    # The .tar.bz2 "Download" link is a binary blob, the source is the .tar.gz!
    url = "https://download.clipgrab.org/${pname}-${version}.tar.gz";
  };

  buildInputs = [ ffmpeg_3 qtbase qtdeclarative qtlocation qtquickcontrols2 qtwebchannel qtwebengine ];
  nativeBuildInputs = [ qmake qttools ];

  postPatch = lib.optionalString (ffmpeg_3 != null) ''
  substituteInPlace converter_ffmpeg.cpp \
    --replace '"ffmpeg"' '"${ffmpeg_3.bin}/bin/ffmpeg"' \
    --replace '"ffmpeg ' '"${ffmpeg_3.bin}/bin/ffmpeg '
  '';

  qmakeFlags = [ "clipgrab.pro" ];

  enableParallelBuilding = true;

  desktopItem = makeDesktopItem rec {
    name = "clipgrab";
    exec = name;
    icon = name;
    desktopName = "ClipGrab";
    comment = meta.description;
    genericName = "Web video downloader";
    categories = "Qt;AudioVideo;Audio;Video";
  };

  installPhase = ''
    install -Dm755 clipgrab $out/bin/clipgrab
    install -Dm644 icon.png $out/share/pixmaps/clipgrab.png
    cp -r ${desktopItem}/share/applications $out/share
  '';

  meta = with lib; {
    description = "Video downloader for YouTube and other sites";
    longDescription = ''
      ClipGrab is a free downloader and converter for YouTube, Vimeo, Metacafe,
      Dailymotion and many other online video sites. It converts downloaded
      videos to MPEG4, MP3 or other formats in just one easy step.
    '';
    homepage = "https://clipgrab.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
