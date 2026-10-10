{ inputs, ...}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.flamegraph =
        pkgs.writeShellApplication {
          name = "flamegraph";
          runtimeInputs = with pkgs; [
            chafa
            perf
          ];
          text = ''
            perf record -F 99 -g -- "$@"
            perf script > out.perf
            ${inputs.flamegraph}/stackcollapse-perf.pl out.perf > out.folded
            ${inputs.flamegraph}/flamegraph.pl out.folded > flamegraph.svg
            rm -f out.perf out.folded perf.data*
            chafa flamegraph.svg
          '';
        };
    };
}
