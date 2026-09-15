{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.nixSearchTv = pkgs.writeShellApplication {
        name = "ns";
        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];
        excludeShellChecks = [ "SC2016" ];
        text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
      };
    };
}
