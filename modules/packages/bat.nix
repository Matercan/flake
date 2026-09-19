{
  inputs,
  ...
}:
{
  perSystem =
    {
      ...
    }:
    {
      packages.bat =
        (inputs.wrappers.wrapperModules.bat.apply {
          "bat-config".content = ''
            --theme="Catppuccin Macchiato"
          '';
        }).wrapper;
    };
}
