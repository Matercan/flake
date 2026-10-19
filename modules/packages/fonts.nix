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

    packages.w95fa = pkgs.stdenv.mkDerivation {
      pname = "w95fa";
      version = "1.0";

      src = ../../assets/w95fa.zip;

      unpackPhase = ''
        runHook preUnpack
        ${pkgs.unzip}/bin/unzip $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 *.[ot|wof]f -t $out/share/fonts/truetype
        runHook postInstall
      '';
    };
  };


}
