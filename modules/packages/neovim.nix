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
    importPlugins = plugins: let
      toLuaList = list: 
        if list == [] then "{}" 
        else "{ " + (lib.concatMapStringsSep ", " (x: "\"${x}\"") list) + " }";

      sortedPlugins = lib.lists.sort (p: q: (p.priority or 0) > (q.priority or 0)) plugins;

      lazySpec = lib.concatMapStringsSep ",\n" (
        { name, package, dependencies ? [], config ? "", lazy ? true, ft ? null, cmd ? null, priority ? 0, ... }:
        let
          pkgPath = package.outPath or package;
          
          depSpecs = map (dep: 
            let 
              depPath = dep.outPath or dep;
              depName = dep.pname or (builtins.baseNameOf depPath);
            in "{ dir = \"${depPath}\", name = \"${depName}\" }"
          ) dependencies;

          luaConfig = if config != "" then 
            "function()\n  " + (lib.replaceStrings ["\n"] ["\n  "] (lib.trim config)) + "\nend" 
          else 
            "nil";
          
          specFields = [
            "dir = \"${pkgPath}\""
            "name = \"${name}\""
          ] ++ (if depSpecs != [] then [ ("dependencies = { " + (lib.concatStringsSep ", " depSpecs) + " }")  ] else [])
          ++ [ "lazy = ${if lazy then "true" else "false"}" ]
          ++ (if ft != null then [ "ft = ${toLuaList (lib.splitString "," ft)}" ] else [])
          ++ (if cmd != null then [ "cmd = ${toLuaList (lib.splitString "," cmd)}" ] else [])
          ++ [ "priority = ${toString priority}" ]
          ++ (if config != "" then [ "config = ${luaConfig}" ] else []);
          
        in
        "{\n  " + (lib.concatStringsSep ",\n  " specFields) + "\n}"
      ) sortedPlugins;

      luaLoader = ''
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not (vim.uv or vim.loop).fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        require("lazy").setup({
          ${lazySpec}
        }, {
          checker = { enabled = false },
          change_detection = { enabled = false },
          
          install = { missing = false, colorscheme = { "catppuccin" } },
        })
      '';
    in luaLoader;

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
              gitsigns = true,
              treesitter = true,
              lualine = true,
            },
          }

          vim.cmd("colorscheme catppuccin")

          local macchiato = require("catppuccin.palettes").get_palette "macchiato"


          vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
          vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none", fg = macchiato.peach }) 
          vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "none" })
          vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "none" })

          vim.api.nvim_set_hl(0, "LspReferenceText", { fg = macchiato.caramel, bg = "none" })
          vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = macchiato.mocha, bg = "none" })
          vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = macchiato.milk, bg = "none" })
          vim.api.nvim_set_hl(0, "LspReferenceTarget", { fg = macchiato.rose, bg = "none" })
          vim.api.nvim_set_hl(0, "LspInlayHint", { fg = macchiato.ice, bg = "none" })
          vim.api.nvim_set_hl(0, "LspCodeLens", { fg = macchiato.pearl, bg = "none" })
          vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { fg = macchiato.pearl, bg = "none" })
          vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { fg = macchiato.rose, bg = "none" })

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

          -- Syntax Highlight groups ♡
          vim.api.nvim_set_hl(0, "Comment", { fg = macchiato.teal, italic = true, bold = true })
          vim.api.nvim_set_hl(0, "@comment", { fg = macchiato.teal,  italic = true })

          local keyword_table = { fg = macchiato.mauve, italic = true, bold = true }
          local parameter_table = { fg = macchiato.red, italic = true, bold = true }

          vim.api.nvim_set_hl(0, "@keyword", keyword_table)
          vim.api.nvim_set_hl(0, "Keyword", keyword_table)
          vim.api.nvim_set_hl(0, "Statement", keyword_table)
          vim.api.nvim_set_hl(0, "cStatement", keyword_table)
          vim.api.nvim_set_hl(0, "Conditional", keyword_table)
          vim.api.nvim_set_hl(0, "cConditional", keyword_table)
          vim.api.nvim_set_hl(0, "Repeat", keyword_table)
          vim.api.nvim_set_hl(0, "cRepeat", keyword_table)

          vim.api.nvim_set_hl(0, "@variable.parameter", parameter_table)
          vim.api.nvim_set_hl(0, "@parameter", parameter_table)
          vim.api.nvim_set_hl(0, "@lsp.type.parameter", parameter_table)
          vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration", parameter_table) 
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
        lazy = false;
        config = /* lua */ ''
          local orig_open_floating_preview = vim.lsp.util.open_floating_preview
          vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
              opts = opts or {}
              opts.border = opts.border or "single"
              return orig_open_floating_preview(contents, syntax, opts, ...)
          end
          
          vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              local bufnr = ev.buf
          
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
          
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          
          vim.lsp.config('*', {
            capabilities = capabilities,
          })
          
          vim.lsp.enable({ "lua_ls", "nil_ls", "ltex", "clangd", "rust_analyzer", "qmlls" })
          
          vim.diagnostic.config({
            virtual_text = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "single", source = "always" },
          })
        '';
      };

      nvim-cmp = {
        package = pkgs.vimPlugins.nvim-cmp;
        name = "nvim-cmp";
        lazy = false;
        dependencies = [
          pkgs.vimPlugins.nvim-web-devicons
          pkgs.vimPlugins.cmp-nvim-lsp
          pkgs.vimPlugins.cmp_luasnip
          pkgs.vimPlugins.friendly-snippets
          pkgs.vimPlugins.luasnip
          pkgs.vimPlugins.cmp-buffer
        ]; 
        config = /* lua */ ''
          local cmp = require('cmp')
          local luasnip = require('luasnip')

          require('luasnip.loaders.from_vscode').lazy_load()

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            window = {
              completion = {
                border = 'single', 
                winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
              },
              documentation = {
                border = 'single',
                winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
              },
            },
      
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
             sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
            }, {
              { name = 'buffer' },
            }),

            formatting = {
              fields = { "abbr", "kind", "menu" },
              format = function(entry, vim_item)
                local lsp_kind_icons = {
                  Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
                  Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "",
                  Module = "󰏗", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
                  Enum = "", Keyword = "󰌋", Snippet = "󰘍", Color = "󰏘",
                  File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
                  Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
                  TypeParameter = "󰊄",
                }
                
                local has_devicons, devicons = pcall(require, "nvim-web-devicons")
                local kind_icons = has_devicons and devicons.get_icons() or {}
                
                vim_item.kind = (kind_icons[vim_item.kind] or lsp_kind_icons[vim_item.kind] or "?") .. " "
                vim_item.menu = ({
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snippet]",
                  buffer = "[Buffer]",
                  path = "[Path]",
                })[entry.source.name]

                return vim_item
              end,
            },
          })
        '';
      };

      lualine = {
        name = "lualine";
        package = pkgs.vimPlugins.lualine-nvim;
        dependencies = [ pkgs.vimPlugins.nvim-web-devicons ];
        config = /* lua */ ''
          require('lualine').setup()
        '';
      };

      gitsigns = {
        name = "gitsigns";
        package = pkgs.vimPlugins.gitsigns-nvim;
        config = /* lua */ ''require('gitsigns').setup()'';
      };

      wakatime = {
        name = "wakatime";
        package = pkgs.vimPlugins.vim-wakatime;
      };

      oil = {
        name = "oil";
        lazy = false; 
        package = pkgs.vimPlugins.oil-nvim;
        config = /* lua */ ''require('oil').setup()'';
      };

      plugins = importPlugins [
        treesitter
        treesj
        catppuccin

        gitsigns

        lspconfig
        nvim-cmp
        
        lualine
        wakatime
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
          kdePackages.qtdeclarative
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
