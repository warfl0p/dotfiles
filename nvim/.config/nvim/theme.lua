return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      on_highlights = function(hl, c)
        local vsc_teal = "#4EC9B0"
        local vsc_light_blue = "#9CDCFE"
        local vsc_purple = "#C586C0"
        local vsc_yellow = "#DCDCAA"
        local vsc_blue = "#569CD6"
        local vsc_orange = "#CE9178"

        -- ==========================================================
        -- 1. BASE SYNTAX (Treesitter)
        -- ==========================================================
        hl["@function"] = { fg = vsc_yellow }
        hl["@function.call"] = { fg = vsc_yellow }
        hl["@method"] = { fg = vsc_yellow }
        hl["@method.call"] = { fg = vsc_yellow }

        hl["@variable"] = { fg = vsc_light_blue }
        hl["@variable.member"] = { fg = vsc_light_blue }
        hl["@parameter"] = { fg = vsc_light_blue }

        -- Force Classes and Types to Teal
        hl["@type"] = { fg = vsc_teal }
        hl["@type.builtin"] = { fg = vsc_teal }
        hl["@type.python"] = { fg = vsc_teal }
        hl["@module"] = { fg = vsc_teal } -- Treesitter module
        hl["@constructor"] = { fg = vsc_teal }
        hl["@constructor.python"] = { fg = vsc_teal }

        hl["@keyword"] = { fg = vsc_purple }
        hl["@keyword.import"] = { fg = vsc_purple }
        hl["@keyword.function"] = { fg = vsc_blue } -- 'def' in Blue
        hl["@keyword.return"] = { fg = vsc_purple }

        hl["@string"] = { fg = vsc_orange }
        hl["@number"] = { fg = "#B5CEA8" }
        hl["@constant"] = { fg = "#4FC1FF" }

        -- ==========================================================
        -- 2. SMART HIGHLIGHTING (LSP / Semantic Tokens)
        -- ==========================================================
        -- This fixes 'collections.abc' being blue
        hl["@lsp.type.namespace"] = { fg = vsc_teal }
        hl["@lsp.type.namespace.python"] = { fg = vsc_teal }
        hl["@lsp.type.module"] = { fg = vsc_teal }

        hl["@lsp.type.class"] = { fg = vsc_teal }
        hl["@lsp.type.type"] = { fg = vsc_teal }

        -- Variables and Parameters (keep blue)
        hl["@lsp.type.variable"] = { fg = vsc_light_blue }
        hl["@lsp.type.parameter"] = { fg = vsc_light_blue }

        -- Keywords
        hl["@lsp.type.keyword"] = { fg = vsc_purple }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
