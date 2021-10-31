##################################
###        DEPRECATE           ###
##################################
with import <nixpkgs> {};

let configsRemote = {
       config = {
         url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-config.json";
         sha256 = "1svhgnnxfjil9haml8gmqy6b8l0y57yvr8pw1hsnsl16r4nhb6cr";
       };
       byron = {
         url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-byron-genesis.json";
         sha256 = "1ahkdhqh07096law629r1d5jf6jz795rcw6c4vpgdi5j6ysb6a2g";
       };
       shelley = {
         url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-shelley-genesis.json";
         sha256 = "0qb9qgpgckgz8g8wg3aa9vgapym8cih378qc0b2jnyfxqqr3kkar";
       };
       topology = {
         url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-topology.json";
         sha256 = "0c2p6vznyl96l2f1f5phkhdwckvy3d8515apgpl744jxym7iihks";
       };
    };
  # f = fetchurl {
  #   url = "https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json";
  #   #   "https://hydra.iohk.io/build/6198010/download/1/mainnet-config.json"
  #   # "https://hydra.iohk.io/build/6198010/download/1/mainnet-byron-genesis.json"
  #   #     "https://hydra.iohk.io/build/6198010/download/1/mainnet-shelley-genesis.json"
  #   #     "https://hydra.iohk.io/build/6198010/download/1/mainnet-topology.json"
  #   sha256 = "14hdlk5jqwxbvb97dywv7g3jvfs98kb5423bffl638qsc7m65df7";
  #   postFetch = "sed -e 's/mainnet/----/' $downloadedFile > $out";
  #   downloadToTemp = true;
  # };
    # readParse = name: urldata: with builtins; fromJSON (readFile (fetchurl urldata));
    # https://github.com/NixOS/nixpkgs/commit/8252861507ef85b45f739c63f27d4e9a80b31b31
    # pkgs.lib.pipe urldata [fetchurl readFile fromJSON]
    # readParse = name: urldata: with builtins; fromJSON (readFile (fetchurl urldata));

    readParse = with builtins; with lib; name: urldata: pipe urldata [fetchurl readFile fromJSON];
    writeConf = with builtins; name: data: toFile "${name}.json" (toJSON data);
  in
with builtins;
rec {
  res = builtins.mapAttrs readParse configsRemote;
  byronPath = toFile "byron.json" (toJSON res.byron);
  shelleyPath = toFile "shelley.json" (toJSON res.shelley);


  conf = res.config // {
    # derivation based config paths
    ByronGenesisFile = byronPath;
    ShelleyGenesisFile = shelleyPath;

    # Monitoring
    TraceBlockFetchDecisions = true;
    setupBackends = [
      "KatipBK"
      "EKGViewBK"
    ];
    hasPrometheus = [ "0.0.0.0" 12798 ];
  };

  configPath = toFile "config.json" ( toJSON conf );
  topologyPath = toFile "topology.json" ( toJSON res.topology );
  # files = mapAttrs writeConf res;
}
# stdenv.mkDerivation {
#   name = "mainnet-config2";
#   src = f;

#   dontUnpack = true;
#   installPhase = "mkdir -p $out; cp $src $out/";
# }
