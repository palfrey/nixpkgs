{ stdenv
, lib
, fetchFromGitLab
, meson
, ninja
, pkg-config
, cjson
, cmocka
, mbedtls
}:

stdenv.mkDerivation rec {
  pname = "librist";
  version = "0.2.11";

  src = fetchFromGitLab {
    domain = "code.videolan.org";
    owner = "rist";
    repo = "librist";
    rev = "v${version}";
    hash = "sha256-xWqyQl3peB/ENReMcDHzIdKXXCYOJYbhhG8tcSh36dY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cjson
    cmocka
    mbedtls
  ];

  meta = with lib; {
    description = "Library that can be used to easily add the RIST protocol to your application";
    homepage = "https://code.videolan.org/rist/librist";
    license = with licenses; [ bsd2 mit isc ];
    maintainers = with maintainers; [ raphaelr sebtm ];
    platforms = platforms.all;
  };
}
