{
  stdenv, lib,
  fetchurl,
  unzip,
}:
let
  inherit (stdenv.hostPlatform) system;
  # https://hydra.iohk.io/jobset/Cardano/tools
  url = {
    x86_64-linux = {
      url = "https://hydra.iohk.io/build/7812191/download/1/x86_64-unknown-linux-musl-cardano-node-1.30.1.zip";
      sha256 = "027g0r5dc40zflnqvj91x2c0irs4igivfhqn1m6v7l8s1m965svg";
    };
    x86_64-darwin = {
      url = "https://hydra.iohk.io/build/7812189/download/1/x86_64-apple-darwin-cardano-node-1.30.1.zip";
      sha256 = "14lvcxwhzr21sh7qw5vwh4kz209swg665b2y86x98j6y5l3dykjh";
    };
    aarch64-linux = {
      url = "https://hydra.iohk.io/build/7812190/download/1/aarch64-unknown-linux-musl-cardano-node-1.30.1.zip";
      sha256 = "0r6vplsnzigzkcnjwivknkiy8via51w8m3pvfjj4z668rnpg44db";
    };
  }.${system};
in

stdenv.mkDerivation rec {
  name = "cardano-node-alt-${version}";
  version = "1.30.1";

  src = fetchurl url;

  nativeBuildInputs = [
    unzip
  ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    chmod +x cardano-node/*
    cp -r cardano-node/* $out/bin
'';
}
