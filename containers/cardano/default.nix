{ config, lib, pkgs, ... }:

with lib;
let
  inherit (pkgs.stdenv.hostPlatform) system;
  configOptionKey = "cardano-container";
  cardanoPkg = pkgs.cardano-node;
  guildToolsPkg = pkgs.guild-tools;
  b2sum-arm = pkgs.b2sum-arm;
  cncli = pkgs.cncli;
  bech32 = pkgs.bech32;
  cardanoConf = import ./config-files.nix { inherit pkgs; };
  serviceConf = import ../../services/cardano { inherit lib; };
  eachAda = config.${configOptionKey};

  adaOpts = {config, lib, name, ...}:
    let cfg = eachAda."${name}";
    in {

      options = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Enable Cardano node service.";
        };

        autostart = mkOption {
          default = true;
          type = types.bool;
          description = "Start container on boot";
        };

        name = mkOption {
          default = "cardano";
          type = types.str;
          description = "name of service.";
        };

        network = mkOption {
          default = "mainnet";
          type = types.enum [ "mainnet" "testnet" "alonzo" ];
        };

        stateDir = mkOption {
          default = "/var/lib/cardano";
          type = types.str;
          description = "cardano data directory.";
        };

        bindStateDir = mkOption {
          default = false;
          type = types.bool;
          description = "wether to bind state directory from host to container.";
        };

        sharedDir = mkOption {
          default = "${cfg.stateDir}/shared";
          type = types.str;
        };

        bindSharedDir = mkOption {
          default = false;
          type = types.bool;
        };

        dbDir = mkOption {
          type = types.str;
          default = "${cfg.stateDir}/db";
          description = "Path to cardano database forder.";
        };

        configDir = mkOption {
          type = types.str;
          default = "/etc/cardano";
          description = "Path to folder containing config files.";
        };

        appDir = mkOption {
          type = types.str;
          default = "/opt/cardano";
          description = "Path to work dir containing keys, pool info";
        };

        socketPath = mkOption {
          type = types.str;
          default = "${cfg.dbDir}/node.socket";
          description = "Cardano node communication socket";
        };

        host = mkOption {
          type = types.str;
          default = "0.0.0.0";
          description = "IP address cardano-node to bind to.";
        };

        port = mkOption {
          type = types.port;
          default = 3001;
          description = "Port number cardano-node will be listening on.";
        };

        monitoring = {
          nodeExporter = {
            enable = mkOption {
              default = true;
              type = types.bool;
              description = "Enable Prometheus node-exporter service.";
            };
            port = mkOption {
              type = types.port;
              default = 9100;
              description = "Port for node-exporter.";
            };
          };

          ekg = {
            enable = mkOption {
              default = true;
              type = types.bool;
              description = "Enable EKG";
            };
            port = mkOption {
              type = types.port;
              default = 12788;
              description = "Port for node-exporter.";
            };

          };

          prometheus = {
            enable = mkOption {
              default = true;
              type = types.bool;
              description = "Enable Cardano node Prometheus metrics.";
            };
            port = mkOption {
              type = types.port;
              default = 12798;
              description = "Port for Prometheus.";
            };
            host = mkOption {
              type = types.str;
              default = "0.0.0.0";
              description = "Host for Prometheus.";
            };
          };
        };

        user = mkOption {
          type = types.str;
          default = "cardano";
          description = "User account under which cardano service runs.";
        };

        peers = mkOption {
          type = types.listOf ( types.submodule {
            options = {
              addr = mkOption {
                type = types.str;
              };
              port = mkOption {
                type = types.int;
              };
              valency = mkOption {
                type = types.int;
              };
            };
          } );
          default = [];
        };
        users = mkOption {
          type = types.attrs;
          default = {};
          description = "additional users to use container";
        };

        config-files = let configs = cardanoConf cfg.network; in {
          configPath = mkOption {
            type = types.str;
            default = configs.configPath cfg.monitoring;
            description = "Cardano node config.json file path.";
          };
          topologyPath = mkOption {
            type = types.str;
            default = configs.topologyPath { Producers = cfg.peers; };
            description = "Cardano node topology.json file path.";
          };
          byronPath = mkOption {
            type = types.str;
            default = configs.byronPath;
          };
          shelleyPath = mkOption {
            type = types.str;
            default = configs.shelleyPath;
          };
          alonzoPath = mkOption {
            type = types.str;
            default = configs.alonzoPath;
          };
        };

        package = mkOption {
          default = cardanoPkg;
          type = types.package;
          description = "cardano-node derivation to use";
        };

        extraPackages = mkOption {
          default = [];
          type = types.listOf types.package;
          description = "Packages to be included in container.";
        };

        producer = {
          enable = mkOption {
            default = false;
            type = types.bool;
            description = "Enable Producer operation";
          };

          keysDir = mkOption {
            type = types.str;
            default = "${cfg.appDir}/producer/keys";
          };
          kesKeyPath = mkOption {
            type = types.str;
            default = "${cfg.producer.keysDir}/hot.skey";
          };
          vrfKeyPath = mkOption {
            type = types.str;
            default = "${cfg.producer.keysDir}/vrf.skey";
          };
          opCert = mkOption {
            type = types.str;
            default = "${cfg.producer.keysDir}/op.cert";
          };
        };

        guild-tools = {
          enable = mkOption {
            default = false;
            type = types.bool;
            description = "Enable guild-operators toolset";
          };
          # package = {
          #   default = guildToolsPkg;
          #   type = types.package;
          #   description = "guild-tools derivation to use";

          # };
          dir = mkOption {
            default = "${cfg.appDir}/guild-tools";
            type = types.str;
            description = "folder to store guild-tools files.";
          };
          walletsDir = mkOption {
            default = "${cfg.guild-tools.dir}/priv/wallet";
            type = types.str;
            description = "folder to store wallets.";
          };
          poolsDir = mkOption {
            default = "${cfg.guild-tools.dir}/priv/pool";
            type = types.str;
            description = "folder to store pool data.";
          };
          pool-folder = mkOption {
            default = "";
            description = "Active pool folder name insige poolsDir used for leaderlog calculation";
          };
          d-param = mkOption {
            default = "0";
            description = "Ledger d param";
            type = types.str;
          };
          topology = {
            enable = mkOption {
              default = false;
              type = types.bool;
            };
            port = mkOption {
              default = cfg.port;
              type = types.port;
              description = "external visible port.";
            };
            host = mkOption {
              type = types.str;
              default = cfg.host;
            };
          };
          cncli-sync = {
            enable = mkOption {
              default = false;
              type = types.bool;
            };
          };
        };
      };
    };
in
{
  options = {
    ${configOptionKey} = mkOption {
      type = types.attrsOf ( types.submodule adaOpts );
      default = { };
    };
  };

  config = mkIf ( eachAda != { } ) {
    containers = mapAttrs' (contName: cfg: (
      nameValuePair contName (mkIf cfg.enable {
      autoStart = cfg.autostart;

      forwardPorts = [
        { hostPort = cfg.port; }
      ]
      ++ optional cfg.monitoring.nodeExporter.enable
        { hostPort = cfg.monitoring.nodeExporter.port; }
      ++ optional cfg.monitoring.prometheus.enable
        { hostPort = cfg.monitoring.prometheus.port; };

      bindMounts =  {
        ${cfg.stateDir} = mkIf cfg.bindStateDir {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
        ${cfg.sharedDir} = mkIf cfg.bindSharedDir {
          hostPath = cfg.sharedDir;
          isReadOnly = false;
        };
      };

      config = { config, pkgs, ... }:
        let enableGuildTools = ( if builtins.hasAttr "guild-tools" cfg
                                 then cfg.guild-tools.enable else false );
            guildToolsArmPkgs = [ b2sum-arm ];
            guildToolsX86Pkgs = with pkgs; [b2sum];
        in
        mkMerge [
        ( serviceConf.env cfg )
        {
          users = cfg.users;

          environment.systemPackages = with pkgs; [
            # cntools deps
          ]
          ++ cfg.extraPackages
          ++ optionals enableGuildTools
            [
              # guildToolsPkg
              # (cfg.guild-tools.package.override {
              (guildToolsPkg.override {
                guildConf = {
                  SOCKET = cfg.socketPath;
                  PORT = cfg.port;
                  EXTERNAL_PORT = cfg.guild-tools.topology.port;
                  CNODE_HOSTNAME = cfg.guild-tools.topology.host;
                  EKG_PORT = cfg.monitoring.ekg.port;
                  CONFIG = cfg.config-files.configPath;
                  CNODE_HOME = cfg.guild-tools.dir;
                  LOG_DIR = "/tmp";
                  POOL_NAME = cfg.guild-tools.pool-folder;
                  BLOCKLOG_DIR = "${cfg.stateDir}/blocklog";
                  DECENTRALIZATION_PARAM=cfg.guild-tools.d-param;
                };
              })
              gnupg
              jq
              bc
              dialog
              # Required for leaderlogs
              cncli
              sqlite

              # mnemonic imports / nfts
              bech32
            ]
          ++
          optionals ( enableGuildTools && system == "aarch64-linux" )
            guildToolsArmPkgs
          ++
          optionals ( enableGuildTools && system != "aarch64-linux" )
            guildToolsX86Pkgs
          ;
          environment.variables = {
            CARDANO_NODE_SOCKET_PATH = cfg.socketPath;
            #   SOCKET = cfg.socketPath;
            #   CONFIG = cfg.config-files.configPath;
            #   ENABLE_CHATTR = "false";
          };

          systemd.services.cardano = serviceConf.service cfg;
          environment.etc = {
            "cardano/config.json" = {
              mode = "0440";
              source = cfg.config-files.configPath;
              user = "cardano";
            };
            "cardano/topology.json" = {
              mode = "0660";
              source = cfg.config-files.topologyPath;
              user = "cardano";
            };
            "cardano/byron.json" = {
              mode = "0440";
              source = cfg.config-files.byronPath;
              user = "cardano";
            };
            "cardano/shelley.json" = {
              mode = "0440";
              source = cfg.config-files.shelleyPath;
              user = "cardano";
            };
            "cardano/alonzo.json" = {
              mode = "0440";
              source = cfg.config-files.alonzoPath;
              user = "cardano";
            };
          };


          programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            pinentryFlavor = "curses";
          };


          services.prometheus.exporters.node =
            mkIf cfg.monitoring.nodeExporter.enable {
              enable = true;
              enabledCollectors = [ "systemd" ];
              port = cfg.monitoring.nodeExporter.port;
            };

          networking.firewall.allowedTCPPorts = [
            cfg.port
          ]
          ++ optional cfg.monitoring.nodeExporter.enable
            cfg.monitoring.nodeExporter.port
          ++ optional cfg.monitoring.prometheus.enable
            cfg.monitoring.prometheus.port;

        }
      ];

      })
    )) eachAda;
  };

}
