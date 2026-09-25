require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.mouse = "a"
-- keep per-buffer options in saved sessions
vim.opt.sessionoptions:append("localoptions")
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"
vim.lsp.inlay_hint.enable(false)
-- LazyVim clears this over SSH; remote_clipboard (top of file) handles OSC 52 there
vim.opt.clipboard = "unnamedplus"
