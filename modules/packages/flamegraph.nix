{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.nixSearchTv = pkgs.writeShellApplication {
        name = "flamegraph";
        runtimeInputs = [];
        text = ''
          perf record -F 99 -g -- $@ 
          perf script > out.perf
          stackcollapse-perf.pl out.perf > out.folded
          flamegraph.pl out.folded > flamegraph.svg
          rm out.perf out.folded perf.data*
          chafa flamegraph.svg
        '';
      };
    };
}
