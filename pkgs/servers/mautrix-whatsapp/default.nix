{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "mautrix-whatsapp-unstable";
  version = "2019-11-17";

  src = fetchFromGitHub {
    owner = "tulir";
    repo = "mautrix-whatsapp";
    rev = "0fba1db6aa88a95ff567f44aa9be7ce6ef24787f";
    sha256 = "07cgpvicr6n897myx86mlnx7bydsxnf51lnjbv9dl5yyii73f957";
  };

  patches = [ ./0001-Add-missing-go-dependencies-to-go.sum.patch ];

  modSha256 = "03siqazacbwp0l44hpm1bdr20ds8ivy32nvw1pl6qk7y8fr848j6";

  meta = with stdenv.lib; {
    homepage = https://github.com/tulir/mautrix-whatsapp;
    description = "Matrix <-> Whatsapp hybrid puppeting/relaybot bridge";
    license = licenses.agpl3;
    maintainers = with maintainers; [ vskilet ma27 ];
  };
}
