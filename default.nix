self: super: {
  cardano-node        = self.callPackage ./packages/cardano/cardano-node.nix {};
  cardano-node-alt    = self.callPackage ./packages/cardano/cardano-node-alt.nix {};
  guild-tools         = self.callPackage ./packages/guild-operators-scripts/guild-tools.nix {};
  cncli               = self.callPackage ./packages/cncli {};
  bech32              = self.callPackage ./packages/bech32 {};
  b2sum-arm           = self.callPackage ./packages/b2sum-arm {};
}
