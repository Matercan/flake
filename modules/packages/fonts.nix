{ ... }:

{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.firaCodeIScript = pkgs.callPackage pkgs.stdenv.mkDerivation {
        pname = "firaCodeIScript";
        version = "1.0.0";

        src = ../../assets/firacodeiscript.zip;

        unpackPhase = ''
          runHook preUnpack
          ${pkgs.unzip}/bin/unzip $src;

          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          install -Dm644 FiraCodeiScript-master/*.tff -t $out/share/fonts/truetype

          runHook postInstall
        '';
      };
    };
}
