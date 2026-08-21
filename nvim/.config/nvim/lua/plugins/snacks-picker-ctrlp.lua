-- Make the "smart" picker (buffers + recent files + all files) also search
-- gitignored/hidden files (so .env is findable), but skip .venv/.git noise.
--
-- .venv files are excluded from the broad "files" search entirely, but if
-- one was actually opened (e.g. jumping into a dependency), it's still kept
-- in the recent/buffers list for MRU browsing. Its `text` is blanked so the
-- fuzzy matcher can never match it once you start typing (an empty pattern
-- always matches everything, a non-empty one never matches "") — so it only
-- shows up in the blank Ctrl+P view, not while actively searching.
local function is_venv(item)
  return item.file and item.file:find("/.venv/", 1, true) ~= nil
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          smart = {
            multi = {
              "buffers",
              "recent",
              { source = "files", hidden = true, ignored = true, exclude = { ".venv", ".git" } },
            },
            transform = function(item, ctx)
              local kept = require("snacks.picker.transform").unique_file(item, ctx)
              if kept == false then
                return false
              end
              if is_venv(item) then
                item.text = ""
              end
              return item
            end,
          },
        },
      },
    },
  },
}
