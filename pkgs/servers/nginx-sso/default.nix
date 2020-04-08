{ buildGoModule, fetchFromGitHub, fetchpatch, stdenv }:

buildGoModule rec {
  pname = "nginx-sso";
  version = "0.24.1";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "Luzifer";
    repo = "nginx-sso";
    sha256 = "1wij0a5ban2l6ahfra4n4dji7i5ndkqk1mgrblwm2ski7bl8yszx";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/nyanloutre/nginx-sso/commit/a0a72804ab484830746e547bef1a2b5ca4e98e1b.patch";
      sha256 = "1kyp8pzgk3s7g98dk8mad1864v5akcn8p030bdinqn9vx6jrzlv8";
    })
  ];

  modSha256 = "0ifka2dcy5j6236hgi3b2bydyl8m1ciwyq2m3jgmlg89hd1zqf6y";

  postInstall = ''
    mkdir -p $out/share
    cp -R $src/frontend $out/share
  '';

  meta = with stdenv.lib; {
    description = "SSO authentication provider for the auth_request nginx module";
    homepage = https://github.com/Luzifer/nginx-sso;
    license = licenses.asl20;
    maintainers = with maintainers; [ delroth ];
    platforms = platforms.unix;
  };
}
