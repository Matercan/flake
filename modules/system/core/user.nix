{
  self,
  ...
}:
{
  flake.nixosModules.user =
    { system, ... }:
    {
      users.users = {
        root = {
          shell = self.packages.${system}.zsh;
          initialPassword = "password";
        };
        lili = {
          isNormalUser = true;
          initialPassword = "password";
          shell = self.packages.${system}.zsh;
          description = "lili";
          extraGroups = [
            "root"
            "wheel"
          ];
        };
      };
    };
}
