{
  stdenv   ,
  lib      ,
  fetchurl ,
  unzip    ,
}:

let
  inherit (stdenv.hostPlatform) system;
  # https://github.com/input-output-hk/cardano-node/releases
  url = {
    x86_64-linux = {
      url = "https://hydra.iohk.io/build/7739415/download/1/cardano-node-1.30.1-linux.tar.gz";
      sha256 = "0m0v1hks2illnd7p4330gj6bd5ih07svz107bc3x3036k0cghwlc";
    };
    x86_64-darwin = {
      url = "https://hydra.iohk.io/build/7739444/download/1/cardano-node-1.30.1-macos.tar.gz";
      sha256 = "0y15n9ab4p9jwb1ynjdfcw8pnd6x1nkj0kc8m0fqbcp2wy859j2l";
    };
  }.${system};
in
stdenv.mkDerivation rec {
  name = "cardano-${version}";
  version = "1.30.1";

  src = fetchurl url;

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    chmod +x cardano-*
    cp cardano-node $out/bin
    cp cardano-cli $out/bin
''
  + (if stdenv.isDarwin
      then  "\n cp *.dylib $out/bin"
      else "");

}
