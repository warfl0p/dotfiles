-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ctrl+p: VSCode-style Ctrl+P via fff.nvim (frecency-ranked fuzzy file finder;
-- recently/frequently opened files rank higher automatically, see lua/plugins/fff.lua)
vim.keymap.set("n", "<C-p>", function()
  require("fff").find_files()
end, {
  desc = "Find files (frecency-ranked, VSCode-style)",
  noremap = true,
  silent = true,
})

-- ctrl+backspace in insert mode
vim.keymap.set("i", "<C-h>", "<C-w>", { noremap = true, silent = true })

-- Open current file in Obsidian via URI
vim.keymap.set("n", "<leader>o", function()
  local function urlencode(str)
    if str then
      str = str:gsub("([^%w%-._~])", function(c)
        return string.format("%%%02X", string.byte(c))
      end)
    end
    return str
  end
  local obs_uri = "obsidian://open?path=" .. urlencode(vim.fn.expand("%:p:h") .. "/" .. vim.fn.expand("%:t"))

  -- open URI
  vim.fn.jobstart({ "xdg-open", obs_uri })
end, { desc = "Open current file in Obsidian" })
