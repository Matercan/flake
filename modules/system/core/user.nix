{
  self,
  ...
}:
{
  flake.nixosModules.user = {
    users.users = {
      root = {
        shell = self.packages.zsh;
      };
      lili = {
        isNormalUser = true;
        initialPassword = "password";
        shell = self.packages.zsh;
        description = "lili";
        extraGroups = [
          "root"
          "wheel"
        ];
      };
    };
  };
}
