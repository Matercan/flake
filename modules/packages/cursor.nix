{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.xcursor-pixel = pkgs.stdenv.mkDerivation {
      pname = "xcursor-pixel";
      version = "1.2";

      src = ../../assets/xcursor-pixel.tar.gz;

      unpackPhase = ''
        runHook preUnpack
        tar -xzf $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/icons
        cp -r pixelfun3 $out/share/icons

        runHook postInstall
      '';
    };
  };
}
