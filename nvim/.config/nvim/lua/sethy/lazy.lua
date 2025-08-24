return require("lazy").setup({
  -- Colorscheme: Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.catppuccin_flavour = "mocha"  -- options: latte, frappe, macchiato, mocha
      require("catppuccin").setup({})
      vim.cmd([[colorscheme catppuccin]])
    end,
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  -- nvim-cmp for completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",  -- <- add this
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })

      -- **CMP for command-line mode**
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Other essentials
  { "numToStr/Comment.nvim" },
  { "windwp/nvim-autopairs" },

  -- Wilder
  { "gelguy/wilder.nvim" },

  -- Render Markdown
  { "MeanderingProgrammer/render-markdown.nvim" },
})
