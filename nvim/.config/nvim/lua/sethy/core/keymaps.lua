local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "   -- sets leader to space

-- Find files
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
-- Find hidden files
vim.api.nvim_set_keymap(
  "n",
  "<leader>fh",
  "<cmd>lua require('telescope.builtin').find_files({ hidden = true, no_ignore = true })<cr>",
  opts
)
-- Search text in project
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
-- Open buffers
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy file path to clipboard" })

-- Toggle LSP diagnostics visibility
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
    isLspDiagnosticsVisible = not isLspDiagnosticsVisible
    vim.diagnostic.config({
        virtual_text = isLspDiagnosticsVisible,
        underline = isLspDiagnosticsVisible
    })
end, { desc = "Toggle LSP diagnostics" })

