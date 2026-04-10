return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				pyright = {},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "ruff_format" },
			},
		},
	},

	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"ruff",
			},
		},
	},
}
