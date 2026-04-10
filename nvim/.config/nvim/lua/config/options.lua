-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.mouse = "a"
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"
vim.lsp.inlay_hint.enable(false)
local is_vscode = vim.g.vscode == 1
local is_ssh = vim.env.SSH_CONNECTION ~= nil

if is_vscode then
  -- VS Code handles clipboard itself
  vim.opt.clipboard = "unnamedplus"
elseif is_ssh then
  -- OSC52 for remote sessions
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }

  vim.opt.clipboard = "unnamedplus"
else
  -- Local machine (Wayland/X11/macOS)
  vim.opt.clipboard = "unnamedplus"
end
