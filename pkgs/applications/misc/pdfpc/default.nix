{ stdenv, fetchFromGitHub, cmake, pkgconfig, vala, gtk3, libgee, fetchpatch
, poppler, libpthreadstubs, gstreamer, gst-plugins-base, gst-plugins-good, gst-libav, librsvg, pcre, gobject-introspection, wrapGAppsHook
, webkitgtk, discount, json-glib }:

stdenv.mkDerivation rec {
  name = "${product}-${version}";
  product = "pdfpc";
  version = "4.5.0";

  src = fetchFromGitHub {
    repo = product;
    owner = product;
    rev = "v${version}";
    sha256 = "0bmy51w6ypz927hxwp5g7wapqvzqmsi3w32rch6i3f94kg1152ck";
  };

  nativeBuildInputs = [
    cmake pkgconfig vala
    # For setup hook
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3 libgee poppler
    libpthreadstubs librsvg pcre
    gstreamer
    gst-plugins-base
    (gst-plugins-good.override { gtkSupport = true; })
    gst-libav
    webkitgtk
    discount
    json-glib
  ];

  cmakeFlags = stdenv.lib.optional stdenv.isDarwin "-DMOVIES=OFF";

  meta = with stdenv.lib; {
    description = "A presenter console with multi-monitor support for PDF files";
    homepage = "https://pdfpc.github.io/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ pSub ];
    platforms = platforms.unix;
  };

}
