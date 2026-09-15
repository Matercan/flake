{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    {
      packages.zsh =
        (inputs.wrappers.wrapperModules.zsh.apply {
          inherit pkgs;

          extraPackages = with pkgs; [
            eza
            asciiquarium-transparent
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
          };

          extraRC = /* bash */ ''
            echo "おかえりなさ～い!♡"

            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi

            ZINIT_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

            if [ ! -d "$ZINIT_HOME" ]; then 
              mkdir -p "''${ZINIT_HOME%/*}"
              git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
            fi

            source "$ZINIT_HOME/zinit.zsh"

            zinit light zsh-users/zsh-syntax-highlighting
            zinit light zsh-users/zsh-autosuggestions
            zinit light Aloxaf/fzf-tab
            zinit ice depth=1; zinit light romkatv/powerlevel10k

            zinit cdreplay -q

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

            zinit light z-shell/zsh-morpho
            zstyle ":morpho" screen-saver "${lib.getExe pkgs.asciiquarium-transparent}"
            zstyle ":morpho" arguments "-t"
            zstyle ":morpho" delay "290"
            zstyle ":morpho" check-interval "60"

            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

            bindkey -e
            bindkey '^p' history-search-backward
            bindkey '^n' history-search-forward
          '';
        }).wrapper;
    };
}
