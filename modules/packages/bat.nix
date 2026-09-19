{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.bat =
        (inputs.wrappers.wrapperModules.bat.apply {
          inherit pkgs;
          "bat-config".content = ''
            --theme="Catppuccin Macchiato"
          '';
        }).wrapper;
    };
}
