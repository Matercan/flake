{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.flamegraph =
        let
          fromGithub = pkgs.fetchFromGitHub {
            owner = "brendangregg";
            repo = "FlameGraph";
            rev = "v1.0";
            hash = "sha256-FGgiwLD0EK5/P6kyXjH2K9WLQgJhFrGLJ7xdiKcciN0=";
          };
        in
        pkgs.writeShellApplication {
          name = "flamegraph";
          runtimeInputs = with pkgs; [
            chafa
            perf
          ];
          text = ''
            perf record -F 99 -g -- "$@"
            perf script > out.perf
            ${fromGithub}/stackcollapse-perf.pl out.perf > out.folded
            ${fromGithub}/flamegraph.pl out.folded > flamegraph.svg
            rm -f out.perf out.folded perf.data*
            chafa flamegraph.svg
          '';
        };
    };
}
