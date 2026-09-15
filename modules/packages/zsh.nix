{
  perSystem =
    {
      pkgs,
      self',
      inputs',
      lib,
      ...
    }:
    {
      packages.zsh = inputs'.wrappers.wrappers.zsh.wrap {
        inherit pkgs;

        shellAliases = {
          ls = "${lib.getExe pkgs.eza}";
          v = "${lib.getExe self'.packages.nvim}";
          cat = "${lib.getExe self'.packages.bat}";
          update = "${lib.getExe self'.packages.nh}";
          svim = "sudo -e";
        };

        integrations = {
          fzf.enable = true;
          zoxide = {
            enable = true;
            flags = [
              "--cmd"
              "cd"
            ];
          };
        };

        completion = {
          enable = true;
          colors = true;
          extraCompletions = true;
          caseInsensitive = true;
          fuzzySearch = true;
        };

        history = {
          size = 1000;
          file = "~/.zsh_history";
          append = true;
          share = true;
          ignoreDups = true;
          ignoreSpace = true;
          findNoDups = true;
          saveNoDups = true;
        };

        zshrc.content = /* bash */ ''
          bindkey -e
          bindkey '^p' history-search-backward
          bindkey '^n' history-search-forward
        '';
      };
    };
}
