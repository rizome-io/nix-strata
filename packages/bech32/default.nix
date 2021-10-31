{
  pkgs     ? import <nixpkgs> {},
  stdenv   ? pkgs.stdenv,
  lib      ? pkgs.lib
}:
with pkgs;
let bech =
      { mkDerivation, array, base, base58-bytestring, bytestring
      , containers, deepseq, extra, hspec, hspec-discover, lib, memory
      , optparse-applicative, process, QuickCheck, text, vector
      }:
      mkDerivation {
        pname = "bech32";
        version = "1.1.1";
        sha256 = "0ibdibki3f51wpxby3cl6p0xzd32ddczlg2dcqxy7lgx7j3h9xgn";
        # isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          array base bytestring containers extra text
        ];
        executableHaskellDepends = [
          base base58-bytestring bytestring extra memory optparse-applicative
          text
        ];
        doCheck = false;
        # testHaskellDepends = [
        #   base base58-bytestring bytestring containers deepseq extra hspec
        #   memory process QuickCheck text vector
        # ];
        # testToolDepends = [ hspec-discover ];
        homepage = "https://github.com/input-output-hk/bech32";
        description = "Implementation of the Bech32 cryptocurrency address format (BIP 0173)";
        license = lib.licenses.asl20;
      };
    drv = haskellPackages.callPackage bech {};
in
drv
