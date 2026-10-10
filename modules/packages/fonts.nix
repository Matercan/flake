{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.firaCodeIScript = pkgs.stdenv.mkDerivation {
      pname = "firaCodeIScript";
      version = "1.0.0";

      src = inputs.firaCodeiScript;

      installPhase = ''
        runHook preInstall
        install -Dm644 ${inputs.firaCodeiScript}/*.ttf -t $out/share/fonts/truetype
        runHook postInstall
      '';
    };
  };
}
