{ lib, stdenv, fetchzip, openmp ? null }:

with lib;

stdenv.mkDerivation {
  pname = "b2sum-arm";
  version = "unstable-2021-08-24";

  src = fetchzip {
    url = "https://github.com/sailnfool/b2sumARM/archive/0b6d8f60c3afb68e001afe51e913155bc07c2cb2.tar.gz";
    sha256 = "02ikan3fw0fmaz696myvs2bpylmzmzyz1h6ixpz8i3pyv4za0nqc";
  };

  sourceRoot = "source/BLAKE2/b2sum";

  buildInputs = [ openmp ];

  buildFlags = [ (optional (openmp == null) "NO_OPENMP=1") ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "The b2sum utility is similar to the md5sum or shasum utilities but for BLAKE2";
    homepage = "https://blake2.net";
    license = with licenses; [ asl20 cc0 openssl ];
    maintainers = with maintainers; [ kirelagin ];
    # "This code requires at least SSE2."
    # platforms = with platforms; [ "x86_64-linux" "i686-linux" ] ++ darwin;
  };
}
