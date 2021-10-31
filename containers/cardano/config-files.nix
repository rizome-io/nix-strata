{ pkgs }:
with pkgs;
with builtins;
# https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html
# https://hydra.iohk.io/build/7189190/download/1/index.html
# https://hydra.iohk.io/build/7366583/download/1/index.html
let
  configsRemote = {
    mainnet = {
      dynamic = {
        config = {
          url = "https://hydra.iohk.io/build/7366583/download/1/mainnet-config.json";
          sha256 = "0mpzayg6i82w9grvwy6p1kb4ql2xrnlml1wp5a2f10pvhakjwy8g";
        };
        topology = {
          url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-topology.json";
          sha256 = "0c2p6vznyl96l2f1f5phkhdwckvy3d8515apgpl744jxym7iihks";
        };
      };
      genesis = {
        byron = {
          url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-byron-genesis.json";
          sha256 = "1ahkdhqh07096law629r1d5jf6jz795rcw6c4vpgdi5j6ysb6a2g";
        };
        shelley = {
          url = "https://hydra.iohk.io/build/6198010/download/1/mainnet-shelley-genesis.json";
          sha256 = "0qb9qgpgckgz8g8wg3aa9vgapym8cih378qc0b2jnyfxqqr3kkar";
        };
        alonzo = {
          url = "https://hydra.iohk.io/build/7366583/download/1/mainnet-alonzo-genesis.json";
          sha256 = "0234ck3x5485h308qx00kyas318dxi3rmxcbksh9yn0iwfpvycvk";
        };
      };
    };
    testnet = {
      dynamic = {
        config = {
          url = "https://hydra.iohk.io/build/7366583/download/1/testnet-config.json";
          sha256 = "1qzhhxa5a5dlqkxwzkxhabgvqsrj5lhl7vn8isqjw3gpf5rn049n";
        };
        topology = {
          url = "https://hydra.iohk.io/build/6782523/download/1/testnet-topology.json";
          sha256 = "0kqm5dzl4iynabzsn9br2gdsiqy3wc9cp3iga6knwr9d3ndr3kyb";
        };
      };
      genesis = {
        byron = {
          url = "https://hydra.iohk.io/build/6782523/download/1/testnet-byron-genesis.json";
          sha256 = "11vxckfnsz174slr7pmb5kqpy8bizkrqdwgmxyzl7fbvj2g178yw";
        };
        shelley = {
          url = "https://hydra.iohk.io/build/6782523/download/1/testnet-shelley-genesis.json";
          sha256 = "19ng3grvz3niashggh0vblf5hw2symp34l4j5d25r7diyz8rlc2f";
        };
        alonzo = {
          url = "https://hydra.iohk.io/build/7366583/download/1/testnet-alonzo-genesis.json";
          sha256 = "0234ck3x5485h308qx00kyas318dxi3rmxcbksh9yn0iwfpvycvk";
        };
      };
    };
    alonzo = {
      dynamic = {
        config = {
          url = "https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-config.json";
          sha256 = "1xysqdwzirm2jp8nk1sp5fr0a9ig3dx1qbvpjcygmgjmrzpm7m4w";
        };
        topology = {
          url = "https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-topology.json";
          sha256 = "1y1n763f3hyz25f5nf29kikrghzxrrv487hw4bwpay7nrjpbm155";
        };
      };
      genesis = {
        byron = {
          url = "https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-byron-genesis.json";
          sha256 = "15mv5ssr8vm3zrg9hxzjrmgjk1hphzvhv08q6rsg58r9rvbrxna2";
        };
        shelley = {
          url = "https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-shelley-genesis.json";
          sha256 = "1ab2x2akvc5l9ql1scim8xp29h1fx5n55cr4vbq6vglr9qdr4vkb";
        };
        alonzo = {
          url = "https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-alonzo-genesis.json";
          sha256 = "0234ck3x5485h308qx00kyas318dxi3rmxcbksh9yn0iwfpvycvk";
        };
      };
    };
  };

    readParse = with lib; name: urldata: pipe urldata [fetchurl readFile fromJSON];
    writeConf = name: data: toFile "${name}.json" (toJSON data);
in

network:
let
  remote = configsRemote.${network};
  res = builtins.mapAttrs readParse remote.dynamic;
in
rec {
  byronPath = fetchurl remote.genesis.byron;
  shelleyPath = fetchurl remote.genesis.shelley;
  alonzoPath = if builtins.hasAttr "alonzo" remote.genesis
               then fetchurl remote.genesis.alonzo
               else null;
  # byronPath = toFile "byron.json" (toJSON res.byron);
  # shelleyPath = toFile "shelley.json" (toJSON res.shelley);


  conf = { prometheus, ekg, ... }:
    let promConf =
          if prometheus.enable
          then {
            TraceBlockFetchDecisions = true;
            # setupBackends = [
            #   "KatipBK"
            #   "EKGViewBK"
            # ];
            hasPrometheus = [ prometheus.host prometheus.port ];

          }
          else { hasPrometheus = null; };
        ekgConf = if !ekg.enable # TODO: not tested
              then { hasEKG = null; }
              else { hasEKG = ekg.port; };
    in
      res.config // promConf // ekgConf // {
        # derivation based config paths
        # ByronGenesisFile = "byron.json";
        # ShelleyGenesisFile = "shelley.json";
        ByronGenesisFile = byronPath;
        ShelleyGenesisFile = shelleyPath;
        AlonzoGenesisFile = if alonzoPath != null
                            then alonzoPath
                            else null;
      };

  configPath = monitoring:
    toFile "config.json" ( toJSON ( conf monitoring ) );
  topologyPath = top:
    let producers = if top.Producers == []
                    then res.topology.Producers
                    else top.Producers;
    in
      toFile "topology.json" ( toJSON (
        res.topology //
        { Producers = producers; }
      ) );
}
