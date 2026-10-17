{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.xcursor-pixel = pkgs.stdenv.mkDerivation {
      pname = "xcursor-pixel";
      version = "1.2";

      src = ../../assets/xcursor-pixel.tar.gz;

      unpackPhase = ''
        runHook preUnpack
        ${pkgs.tar}/bin/tar -xz $src
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 pixelfun3 -t $out/share/icons
        runHook postInstall
      '';
    };
  };
}
