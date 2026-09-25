return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  opts = {
    -- plugin default pins csv -> "," which blocks detection of ";" files
    parser = { delimiter = { ft = { tsv = "\t" } } },
    view = { display_mode = "border" },
  },
  config = function(_, opts)
    require("csvview").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function()
        require("csvview").enable()
      end,
    })
  end,
}
