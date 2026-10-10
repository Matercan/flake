{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    let zsh-morpho = pkgs.fetchFromGitHub {
      owner = "zdharma-continuum";
      repo = "zsh-morpho";
      rev = "410c9b41bf1b9ef51c87b62ec5f50655a0ec1eb4";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    in
    {
      packages.zsh =
        (inputs.wrappers.wrapperModules.zsh.apply {
          inherit pkgs;

          extraPackages = with pkgs; [
            eza
            asciiquarium-transparent
            oh-my-zsh
            zsh-fzf-tab
            nix-zsh-completions
            zsh-completions
            zsh-autosuggestions
            zsh-syntax-highlighting
            zsh-powerlevel10k
          ];

          settings = {
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
          };

          extraRC = /* bash */ ''
             echo "おかえりなさ～い!♡"

             fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions ''${fpath})
             fpath=(${pkgs.zsh-completions}/share/zsh/site-functions ''${fpathfpath})
             autoload -Uz compinit && compinit

             source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh
             source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh
             source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/rust/rust.plugin.zsh
             source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/foot/foot.plugin.zsh
             source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/command-not-found/command-not-found.

             source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

             source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

             source ${zsh-morpho}/zsh-morpho.plugin.zsh
             zstyle ":morpho" screen-saver "${pkgs.asciiquarium-transparent}/bin/asciiquarium-transparent"
             zstyle ":morpho" arguments "-t"
             zstyle ":morpho" delay "290"
             zstyle ":morpho" check-interval "60"

             if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
               source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
             fi

             # Cursor
             function zle-keymap-select {
                 if [[ ''${KEYMAP} == vicmd ]] || [[ $1 = "block" ]]; then
                     echo -ne "\e[1 q"
                 elif [[ ''${KEYMAP} == main ]] || [[ ''${KEYMAP} == viins ]] || [[ ''${KEYMAP} == "" ]] || [[ $1 = "beam" ]]; then
                     echo -ne "\e[5 q"
                 fi
             }

             function zle-line-init {
                 echo -ne "\e[5 q"
             }

             function zle-line-finish {
                 echo -ne "\e[1 q"
             }

             echo -ne "\e[5 q"

             zle -N zle-keymap-select
             zle -N zle-line-init
             zle -N zle-line-finish

             lfcd () {
                 cd "$(command lf -print-last-dir "$@")"
             }
             alias lf='lfcd'


             [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

             bindkey -e
             bindkey '^p' history-search-backward
             bindkey '^n' history-search-forward

            source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-hig
          '';
        }).wrapper;
    };
}
