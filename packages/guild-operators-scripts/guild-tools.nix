{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  guildConf ? {
    CONFIG = "/etc/cardano/config.json";
    PORT = 3001;
    EXTERNAL_PORT = 3001;
    EKG_PORT = 12788;
    SOCKET = "/var/lib/db/node.socket";
    CNODE_HOME = "/opt/cardano/cnode";
    CNODE_HOSTNAME="lucid-rl-0.rizome.io";
    LOG_DIR="/tmp";
    POOL_NAME="";
    BLOCKLOG_DIR="";
    DECENTRALIZATION_PARAM="0";
  }
}:

stdenv.mkDerivation (guildConf // rec {
  name = "guild-tools-${version}";
  version = "1.22.4";
  src = pkgs.fetchFromGitHub {
    owner = "cardano-community";
    repo = "guild-operators";
    rev = "ef5e096586863f63587c2c8b0497d66542931609";
    sha256 = "15ychgd8ija5wpxvxx91yfc2jrzdi38ayrqpng9yxmwa1hjf5p18";
  };

# maybe requierd
# sed -i '567 a return 2' scripts/cnode-helper-scripts/cntools.library
  installPhase = ''
sed -i "s|PARENT=..dirname .0)|PARENT=$out/etc|g" scripts/cnode-helper-scripts/env
sed -i 's|#CNODE_HOME="/opt/cardano/cnode"|CNODE_HOME=${guildConf.CNODE_HOME}|' scripts/cnode-helper-scripts/env
sed -i 's|#SOCKET=".{CNODE_HOME}/sockets/node0.socket"|SOCKET=${guildConf.SOCKET}|' scripts/cnode-helper-scripts/env
sed -i 's|#POOL_NAME=""|POOL_NAME=${guildConf.POOL_NAME}|' scripts/cnode-helper-scripts/env
sed -i 's|#BLOCKLOG_DIR=".{CNODE_HOME}/guild-db/blocklog"|BLOCKLOG_DIR=${guildConf.BLOCKLOG_DIR}|' scripts/cnode-helper-scripts/env

sed -i 's|#CONFIG=".{CNODE_HOME}/files/config.json"|CONFIG=${guildConf.CONFIG}|' scripts/cnode-helper-scripts/env
sed -i 's|CNODE_PORT=6000|CNODE_PORT=${builtins.toString guildConf.PORT}|' scripts/cnode-helper-scripts/env
sed -i 's|#EKG_PORT=12788|EKG_PORT=${builtins.toString guildConf.EKG_PORT}|' scripts/cnode-helper-scripts/env

sed -i 's|#LOG_DIR=".{CNODE_HOME}/logs"|LOG_DIR=${guildConf.LOG_DIR}|' scripts/cnode-helper-scripts/env

sed -i 's|b2sum -l 160 -b|b2sum -l 160|g' scripts/cnode-helper-scripts/env

sed -i "s|PARENT=...dirname .0).|PARENT=$out/etc|g" scripts/cnode-helper-scripts/cntools.sh
sed -i 's/ENABLE_CHATTR=true/ENABLE_CHATTR=false/' scripts/cnode-helper-scripts/cntools.config



sed -i "s|..(dirname .0).|$out/etc|g" scripts/cnode-helper-scripts/cncli.sh
sed -i "s|PARENT=...dirname .0).|PARENT=$out/etc|g" scripts/cnode-helper-scripts/cncli.sh
sed -i "s|leaderlog --db|leaderlog --d ${guildConf.DECENTRALIZATION_PARAM} --db|g" scripts/cnode-helper-scripts/cncli.sh
sed -i 's|#CNCLI_DIR=".{CNODE_HOME}/guild-db/cncli"|CNCLI_DIR=${guildConf.BLOCKLOG_DIR}|g' scripts/cnode-helper-scripts/cncli.sh


sed -i "s|PARENT=...dirname .0).|PARENT=$out/etc|g" scripts/cnode-helper-scripts/gLiveView.sh

sed -i 's|CNODE_HOSTNAME="CHANGE ME"|CNODE_HOSTNAME=${guildConf.CNODE_HOSTNAME}|' scripts/cnode-helper-scripts/topologyUpdater.sh
sed -i '85 a CNODE_PORT=${builtins.toString guildConf.EXTERNAL_PORT}' scripts/cnode-helper-scripts/topologyUpdater.sh
sed -i "s|PARENT=...dirname .0).|PARENT=$out/etc|g" scripts/cnode-helper-scripts/topologyUpdater.sh

    mkdir -p $out/bin $out/etc
    cp scripts/cnode-helper-scripts/env $out/etc
    cp scripts/cnode-helper-scripts/cntools.library $out/etc
    cp scripts/cnode-helper-scripts/cntools.config $out/etc
    cp scripts/cnode-helper-scripts/cntools.sh $out/bin/cntools
    cp scripts/cnode-helper-scripts/cncli.sh $out/bin/gcncli
    cp scripts/cnode-helper-scripts/gLiveView.sh $out/bin/gLiveView
    cp scripts/cnode-helper-scripts/topologyUpdater.sh $out/bin/topologyUpdater
'';
})
