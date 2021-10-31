{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  autoPatchelfHook
}:

stdenv.mkDerivation {
  name = "cncli";

  src = builtins.fetchurl {
    url = "https://github.com/AndrewWestberg/cncli/releases/download/v4.0.1/cncli-4.0.1-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "1f8qk0dp1hji5vxlc9c0az1gh2d49122ivzx4sgbkgna8yhdn6qd";
  };

  buildInputs = with pkgs; [ openssl ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  sourceRoot = ".";

  installPhase = ''
install -m755 -D cncli $out/bin/cncli
'';
}
