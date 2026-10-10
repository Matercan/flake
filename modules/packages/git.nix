{ inputs, ... }:
{
  perSystem = { pkgs, lib, ...}: {
    packages.git = (inputs.wrappers.wrapperModules.git.apply {
      inherit pkgs;

      settings = {
        user = {
          email = "matercan@proton.me";
          name = "liliane";
        };
        core.editor = "nvim";
      };
    }).wrapper;
  };
}
