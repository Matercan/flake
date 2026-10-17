{ ... }:
{
  perSystem = { pkgs, ... }: {
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
        install -Dm644 *.TTF -t $out/share/fonts/truetype
        runHook postInstall
      '';
    };
  };
}
