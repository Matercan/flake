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
      importPlugin =
        {
          package,
          config ? "",
          dependencies ? [ ],
        }:
        let
          prependPlugin = pkg: /* lua */ ''vim.opt.runtimepath:prepend("${pkg}")'';
          prependPlugins = pkgs: lib.concatMapStringsSep "\n" prependPlugin pkgs;
        in
        (prependPlugins dependencies) + (prependPlugin package) + "\n" + config;
      importPlugins = plugins: lib.concatMapStringsSep "\n" importPlugin plugins;

      treesitter = {
        plugin = pkgs.vimPlugins.nvim-treesitter;
        config = /* lua */ ''
          require("nvim-treesitter.configs").setup {
            ensure_installed = { "lua", "python", "json", "c_sharp", "cpp", "c" } ,
            highlight = { enable = true },
            indent = { enable = true },
            folds = { enable = true }, 
          }
        '';

      };

      treesj = {
        plugin = pkgs.vimPlugins.treesj;
        config = /* lua */ ''
            requires('treej').setup {
            vim.keymap.set('m', '<leader>tj', ':TSJToggle <CR>' {})
          }
        '';
      };

      nvimlsp = {
        plugin = pkgs.vimPlugins.cmp-nvim-lsp;
      };

      luasnip = {
        plugin = pkgs.vimPlugins.luasnip;
        dependencies = [
          pkgs.vimPlugins.cmp-luasnip
          pkgs.vimPlugins.friendly-snippets
        ];
      };

      nvim-web-devicons = {
        plugin = pkgs.vimPlugins.nvim-web-devicons;
      };

      nvim-cmp = {
        plugin = pkgs.vimPlugins.nvim-cmp;
        config = /* lua */ ''
          local cmp = require "cmp"
          local luasnip = require "luasnip"
          require "luasnip.loaders.from_vs_code"

          local kind_icons = require("nvim-web-devicons").get_icons()

          local lsp_kind_icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰇽",
              Variable = "󰂡",
              Class = "󰠱",
              Interface = "",
              Module = "󰏗",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "󰘍",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "󰊄",
          }

          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            window = {
              completion = cmp.config.window.bordered {
                border = "single",
              },
              documentation = cmp.config.window.bordered {
                border = "single",
              }
            },
            mapping = cmp.mapping.preset.insert {
              ["<c-b>"] = cmp.mapping.scroll_docs(-4),
              ["<c-f>"] = cmp.mapping.scroll_docs(4),
              ["<c_space>"] = cmp.mapping.complete(),
              ["<c_e>"] = cmp.mapping.abort(),
              ["CR"] = cmp.mapping.confirm { select = true },
            },
            sources = cmp.config.sources(
            {
              { name = "nvim_lsp" }
              { name = "luasnip" },
            }, {
              { name = "buffer" },
            })

            formatting = {
              fields = { "abbr", "kind", "menu" },
              format = function(entry, vim_item)
                vim_item.kind = (kind_icons[vim_item.kind] or lsp_kind_icons[vim_item.kind] or "?") .. " "
                vim_item.menu = ({
                  luasnip = "[Snippet]",
                  buffer = "[Buffer]",
                  path = "Path",
                })[entry.source.name]

                return vim_item
              end,
            },
          }
        '';
      };

      gitsigns = {
        plugin = pkgs.vimPlugins.gitSigns;
        config = /* lua */ ''
          require('gitsigns').setup(),
        '';
      };

      plugins = importPlugins [
        treesitter
        treesj
        gitsigns

        # Completions
        nvimlsp
        luasnip
        nvim-web-devicons
        nvim-cmp
      ];
    in
    {
      packages.nvim = (
        inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.neovim;
          flags = {
            "-u" = builtins.toFile "nvim_config" (
              plugins
              + /* lua */ ''
                vim.opt.expandTab = true
                vim.opt.tabstop = 2
                vim.opt.shiftwidth = 2
                vim.opt.softtabstop = 2
                vim.opt.autoindent = true
                vim.opt.copyindent = true
                vim.opt.smartindent = true
                vim.opt.filetype.indent = true
                vim.opt.number = true
                vim.opt.relativenumber = true
                vim.opt.wrap = false
                vim.g.mapleader = ' '  
                vim.opt.clipboard = "unnamedplus"
                vim.o.foldcolumn = '1'
                vim.o.foldlevel = 99 
                vim.o.foldlevelstart = 99
                vim.o.foldenable = true
                vim.opt.splitright = true
                vim.opt.shell = "${lib.getExe self'.packages.zsh}"
                vim.opt.shellcmdflag = "-c"   
                vim.opt.termguicolors = true
                vim.opt.encoding = "utf-8"
              ''
            );
          };
        }
      );
    };
}
