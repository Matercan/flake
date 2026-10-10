{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      importPlugins =
        plugins:
        let
          toLuaList =
            list:
            if list == [ ] then "{}" else "{ " + (lib.concatMapStringsSep ", " (x: "\"${x}\"") list) + " }";

          # build a Lua table of all plugin definitions
          pluginTable = lib.concatMapStringsSep ",\n" (
            {
              name,
              package,
              dependencies ? [ ],
              config ? "",
              lazy ? false,
              ft ? null,
              cmd ? null,
              ...
            }:
            let
              pkgPath = package.outPath or package;
              depPaths = map (dep: dep.outPath or dep) dependencies;
              luaConfig =
                if config != "" then
                  "function()\n  " + (lib.replaceStrings [ "\n" ] [ "\n  " ] (lib.trim config)) + "\nend"
                else
                  "nil";
            in
            ''
              {
                name = "${name}",
                path = "${pkgPath}",
                dependencies = ${toLuaList depPaths},
                config = ${luaConfig},
                lazy = ${if lazy then "true" else "false"},
                ft = ${if ft != null then "\"${ft}\"" else "nil"},
                cmd = ${if cmd != null then "\"${cmd}\"" else "nil"}
              }
            ''
          ) (lib.lists.sort (p: q: p.priority or 0 < q.priority or 0) plugins);

          # the Lua loader script that processes the table safely
          luaLoader = /* lua */ ''
            local plugins = {
              ${pluginTable}
            }

            local function add_to_rtp(path)
              if path and path ~= "" then
                local rtp = vim.opt.runtimepath:get()
                if not vim.list_contains(rtp, path) then
                  vim.opt.runtimepath:append(path) 
                end
              end
            end

            for _, plugin in ipairs(plugins) do
              for _, dep_path in ipairs(plugin.dependencies) do
                add_to_rtp(dep_path)
              end
              
              add_to_rtp(plugin.path)

              if not plugin.lazy then
                if plugin.config then
                  plugin.config()
                end
              else
                if plugin.ft then
                  vim.api.nvim_create_autocmd("FileType", {
                    pattern = plugin.ft,
                    callback = function()
                      if plugin.config then plugin.config() end
                    end
                  })
                elseif plugin.cmd then
                  vim.api.nvim_create_autocmd("CmdUndefined", {
                    pattern = plugin.cmd,
                    callback = function()
                      if plugin.config then plugin.config() end
                    end
                  })
                else
                  vim.api.nvim_create_autocmd("VimEnter", {
                    callback = function()
                      if plugin.config then plugin.config() end
                    end
                  })
                end
              end
            end
          '';
        in
        luaLoader;

      cmdline-from-source = pkgs.vimUtils.buildVimPlugin {
        name = "telescope-cmdline-nvim";
        src = inputs.telescope-cmdline;
        doCheck = false;
      };

      fzf-native-from-source = pkgs.vimUtils.buildVimPlugin {
        name = "telescope-fzf-native";
        src = inputs.telescope-fzf;
        doCheck = false;
        buildPhase = /* shell */ "make";
        nativeBuildInputs = [
          pkgs.gnumake
          pkgs.gcc
        ];
      };

      treesitter = {
        name = "treesitter";
        package = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        config = /* lua */ ''
          require("nvim-treesitter").setup {
            highlight = { enable = true },
            indent = { enable = true },
            folds = { enable = true } 
          }
        '';
      };

      catppuccin = {
        name = "catppuccin";
        lazy = false;
        priority = 1000;
        package = pkgs.vimPlugins.catppuccin-nvim;
        config = /* lua */ ''
          require("catppuccin").setup {
            flavour = "macchiato",
            background = { light = "latte", dark = "mocha", },
            transparent_background = true,
            term_colors = true,
            compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
            integrations = {
              cmp = true,
              gitsigns = true,
              treesitter = true,
            },
          }

          vim.cmd("colorscheme catppuccin")

          local macchiato = require("catppuccin.palettes").get_palette "macchiato" 

          vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", fg = macchiato.blue })
          vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none", fg = macchiato.blue })
          vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none", fg = macchiato.blue })
          vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none", fg = macchiato.blue })
          vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
          vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none", fg = macchiato.blue })

          vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "none", fg = macchiato.peach, bold = true })
          vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { bg = "none", fg = macchiato.peach })

          vim.api.nvim_set_hl(0, "Normal", { bg = "none" })  
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = macchiato.text })
          vim.api.nvim_set_hl(0, "FloatBorder", { fg = macchiato.blue, bg = "none" })
          vim.api.nvim_set_hl(0, "FloatTitle", { fg = macchiato.lavender, bg = "none", bold = true })

          vim.api.nvim_set_hl(0, "CursorLineNr", { fg = macchiato.peach, bold = true, })
          vim.api.nvim_set_hl(0, "Cursor", { fg = macchiato.lavender, })
        '';
      };

      telescope = {
        name = "telescope";
        package = pkgs.vimPlugins.telescope-nvim;
        lazy = false;
        priority = 1000;
        dependencies = [
          pkgs.vimPlugins.plenary-nvim
          fzf-native-from-source
          cmdline-from-source
        ];

        config = /* lua */ ''
          require("telescope").setup({
            defaults = {
              borderchars = {
                "─",
                "│",
                "─",
                "│",
                "┌",
                "┐",
                "┘",
                "└"
              }
            }, 

            extensions = {
              cmdline = {
                picker = { layout_config = { width = 100, height = 50 } },
                mappings = { 
                  complete = "<Tab>", 
                  run_selection = "<C-CR>",
                  run_input = "<CR>"
                },
                icons = {
                  history = "",
                  command = "",
                  number = "󰉻",
                  unknown = "",
                },
                prompt_prefix = ""
              },
            }
          })

          local builtin = require("telescope.builtin")

          -- Ensure you have telescope-fzf-native.nvim installed and built before loading this
          require('telescope').load_extension('fzf')

          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

          vim.keymap.set('n', 'Q', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
          vim.keymap.set('n', '<leader><leader>', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
        '';
      };

      treesj = {
        name = "treesj";
        package = pkgs.vimPlugins.treesj;
        config = /* lua */ ''
          require('treesj').setup {}
          vim.keymap.set('n', '<leader>tj', '<cmd>TSJToggle<CR>', {})
        '';
      };

      lspconfig = {
        name = "nvim-lspconfig";
        package = pkgs.vimPlugins.nvim-lspconfig;
        config = /* lua */ ''
          print("DEBUG: Starting Native LSP Setup...")

          vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

          local orig_open_floating_preview = vim.lsp.util.open_floating_preview
          vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or "single" -- or "rounded"
            return orig_open_floating_preview(contents, syntax, opts, ...)
          end

          local function set_popup_border(winid)
            if winid and winid >= 0 and vim.api.nvim_win_is_valid(winid) then
              pcall(vim.api.nvim_win_set_config, winid, { border = "single" })
            end
          end

          vim.api.nvim_create_autocmd("CompleteChanged", {
            group = vim.api.nvim_create_augroup("CompletionPopupBorder", { clear = true }),
            callback = function()
              vim.schedule(function()
                local info = vim.fn.complete_info({ "selected" })
                set_popup_border(info.preview_winid)
              end)
            end,
          })

          local orig = vim.api.nvim__complete_set
          vim.api.nvim__complete_set = function(index, opts)
            local windata = orig(index, opts)
            set_popup_border(windata and windata.winid)
            return windata
          end

          vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              local bufnr = ev.buf

              if client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, bufnr, {
                  autotrigger = true, 
                })
              end

              vim.keymap.set("i", "<C-Space>", function()
                vim.lsp.completion.get()
              end, { buffer = bufnr, desc = "Trigger LSP Completion" })

              vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
              local opts = { buffer = bufnr, silent = true, desc = "LSP Action" }

              if client:supports_method("textDocument/hover") then
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              end
              if client:supports_method("textDocument/definition") then
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              end
              if client:supports_method("textDocument/references") then
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              end
              if client:supports_method("textDocument/codeAction") then
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
              end
              
              if client:supports_method("textDocument/formatting") then
                vim.keymap.set("n", "<leader>f", function()
                  vim.lsp.buf.format({ async = true })
                end, opts)
              end
            end,
          })

          vim.lsp.config('*', {
            capabilities = vim.lsp.protocol.make_client_capabilities(),
          })

          vim.lsp.enable({ "lua_ls", "nil_ls", "ltex", "clangd", "rust_analyzer" })

          vim.diagnostic.config({
            virtual_text = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "single", source = "always" },
          })

          print("DEBUG: Native LSP Setup Complete!")
        '';
      };

      nvim-web-devicons = {
        name = "devicons";
        package = pkgs.vimPlugins.nvim-web-devicons;
        config = /* lua */ ''require('nvim-web-devicons').setup()'';
      };

      gitsigns = {
        name = "gitsigns";
        package = pkgs.vimPlugins.gitsigns-nvim;
        config = /* lua */ ''require('gitsigns').setup()'';
      };

      oil = {
        name = "oil";
        package = pkgs.vimPlugins.oil-nvim;
        config = /* lua */ ''require('oil').setup()'';
      };

      plugins = importPlugins [
        treesitter
        treesj
        catppuccin

        gitsigns
        nvim-web-devicons

        lspconfig
        
        oil
        telescope
      ];

      nvim_config = pkgs.writeText "init.lua" (
        /* lua */ ''
          vim.g.mapleader = ' '
          vim.g.localleader = ' '
        ''
        + plugins
        + /* lua */ ''
          vim.opt.expandtab = true
          vim.opt.tabstop = 2
          vim.opt.shiftwidth = 2
          vim.opt.softtabstop = 2
          vim.opt.autoindent = true
          vim.opt.copyindent = true
          vim.opt.smartindent = true
          vim.cmd('filetype plugin indent on')
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.wrap = false
          vim.opt.clipboard = "unnamedplus"
          vim.o.foldcolumn = '1'
          vim.o.foldlevel = 99 
          vim.o.foldlevelstart = 99
          vim.o.foldenable = true
          vim.opt.splitright = true
          vim.opt.shellcmdflag = "-c"   
          vim.opt.encoding = "utf-8"

          vim.keymap.set('n', '<leader>rh', function()
            vim.ui.input({ prompt = 'Find: ' }, function(find_pattern)
                if not find_pattern then return end -- User cancelled

                vim.ui.input({ prompt = 'Replace with: ' }, function(replace_string)
                    replace_string = replace_string or '''

                    local cmd = '%s/' .. find_pattern .. '/' .. replace_string .. '/gc'
                    vim.cmd(cmd)
                end)
              end)
          end, { desc = 'Find and Replace (File)' })
        ''
      );
    in
    {
      packages.nvim = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.neovim;
        runtimeInputs = with pkgs; [
          lua-language-server
          nil
          ltex-ls
          clang-tools
          rust-analyzer
          rustc
          cargo
          ripgrep
          fd
          fzf
        ];
        flags = {
          "-u" = nvim_config;
        };
      };

      packages.nvim-config = pkgs.writeShellApplication {
        name = "nvim-config";
        text = "cat ${nvim_config}";
      };
    };
}
