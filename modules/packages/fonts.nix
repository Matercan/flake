{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.firaCode = pkgs.stdenv.mkDerivation {
      pname = "firaCode";
      version = "6.2";

      src = inputs.firaCode;

      installPhase = ''
        runHook preInstall
        install -Dm644 ${inputs.firaCode}/*.ttf -t $out/share/fonts/truetype
        runHook postInstall
      '';
    };

    packages.script12 = pkgs.stdenv.mkDerivation {
      pname = "script12";
      version = "6.2";

      src = ../../assets/script12.zip;

      unpackPhase = ''
        runHook preUnpack
        ${pkgs.unzip}/bin/unzip $src
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 *.ttf -t $out/share/fonts/truetype
        runHook postInstall
      '';
    };
  };
}
