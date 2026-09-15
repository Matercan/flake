{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.unfreePkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

  flake.nixosModules.nix =
    { ... }:
    {
      nix = {
        settings = {
          cores = 1;
          download-buffer-size = 524288000;
          experiment-features = [
            "nix-command"
            "flakes"
          ];
        };
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        optimise.automatic = true;
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 5d";
        };
      };
      nixpkgs.config.allowUnfree = true;
    };
}
