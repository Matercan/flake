{
  description = "Lili's nix flake";

  outputs =
    { self, ... }@args:
    let inputs = (import ./.tack) {
        overrides = args.tackOverrides or { };
     }; in
     inputs.flake-parts.lib.mkFlake { inherit inputs; self = self // { inherit inputs; }; } (inputs.import-tree ./modules);
}
