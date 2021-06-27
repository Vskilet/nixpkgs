{ buildPecl, lib, php, pkg-config, openssl, libevent }:
buildPecl {
  pname = "event";

  version = "3.0.4";
  sha256 = "13yb3zvlx43cncawymiwbqyz8gzpq1g03vd0xjlw9vz75b4mwn1x";

  configureFlags = [
    "--with-event-libevent-dir=${libevent.dev}"
    "--with-event-core"
    "--with-event-extra"
    "--with-event-pthreads"
  ];

  postPhpize = ''
    substituteInPlace configure --replace \
      'as_fn_error $? "Couldn'\'''t find $phpincludedir/sockets/php_sockets.h. Please check if sockets extension installed" "$LINENO" 5' \
      ':'
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl libevent ];
  internalDeps = [ php.extensions.sockets ];

  meta = with lib; {
    description = ''
      This is an extension to efficiently schedule I/O, time and signal based
      events using the best I/O notification mechanism available for specific platform.
    '';
    license = licenses.php301;
    homepage = "https://bitbucket.org/osmanov/pecl-event/";
    maintainers = teams.php.members;
  };
}
