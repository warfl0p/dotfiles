return {
  "dmtrKovalenko/fff",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  lazy = false, -- the plugin lazy-initialises itself
  config = function()
    -- Empty query: show most recently opened files first (fff's own ranking
    -- mixes in mtime and git recency). As soon as you type, fff ranks normally.
    -- ponytail: monkey-patches fff internals and only reorders the first page;
    -- drop this if fff gets an upstream option for it.
    local recent, tick = {}, 0
    for i = #vim.v.oldfiles, 1, -1 do
      tick = tick + 1
      recent[vim.v.oldfiles[i]] = tick
    end
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function(ev)
        local name = vim.api.nvim_buf_get_name(ev.buf)
        if name ~= "" and vim.bo[ev.buf].buftype == "" then
          tick = tick + 1
          recent[name] = tick
        end
      end,
    })

    local fp = require("fff.file_picker")
    local search = fp.search_files_paginated
    fp.search_files_paginated = function(query, current_file, max_threads, min_combo, page_index, page_size)
      local items = search(query, current_file, max_threads, min_combo, page_index, page_size)
      local res = fp.state.last_search_result
      if query ~= "" or (page_index or 0) ~= 0 or not res or res.items ~= items then return items end

      local cwd = (fp.state.base_path or vim.fn.getcwd()) .. "/"
      local order = {}
      for i = 1, #items do order[i] = i end
      local function rank(i)
        local path = cwd .. items[i].relative_path
        return path ~= current_file and recent[path] or 0 -- current file keeps fff's penalty
      end
      table.sort(order, function(a, b)
        local ra, rb = rank(a), rank(b)
        if ra ~= rb then return ra > rb end
        return a < b -- stable: keep fff's order among never-opened files
      end)

      local sorted, scores = {}, {}
      for i, j in ipairs(order) do
        sorted[i] = items[j]
        scores[i] = res.scores and res.scores[j]
      end
      res.items, res.scores = sorted, res.scores and scores
      return sorted
    end
  end,
}
