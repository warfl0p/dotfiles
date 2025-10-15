-- Bootstrap lazy.nvim if it isn't installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- make d delete without yanking
vim.keymap.set({"n", "x"}, "d", '"_d')
-- make x cut (delete with yank)
vim.keymap.set({"n", "x"}, "x", 'd')

if vim.g.vscode then
  -- Only active in VSCode Neovim extension
  vim.opt.clipboard = "unnamedplus"
  vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
else
  
  -- All your normal Neovim config
  require("sethy.core")
  require("sethy.lazy")

  -- Clipboard integration
  if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
      },
      paste = {
        ["+"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
        ["*"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
      },
      cache_enabled = 0,
    }
  end
end
