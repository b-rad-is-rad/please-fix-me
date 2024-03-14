local M = require("config")

M.highlight = function (buf, filetype, first_line_num, last_line_num)
  -- get the lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(buf, first_line_num, last_line_num, false)
  local comment_syntax = M.config.lang_comment_syntax[filetype].s
  local escaped_comment_syntax = ""

  for i=1, #comment_syntax do
    local c = comment_syntax:sub(i,i)
    escaped_comment_syntax = escaped_comment_syntax .. "%" .. c
  end

  -- search lines
  for i, line in ipairs(lines) do
    if line:match("^%s*" .. escaped_comment_syntax) then
      local j = 1

      -- highlight line
      while true do
        local word_start, word_end = string.find(line, "FIXME", j)

        if word_start and word_end then
          j = word_end

          vim.api.nvim_buf_add_highlight(
            buf,
            M.hl_ns_id,
            "FixMe",
            first_line_num + i - 1,
            word_start - 1,
            word_end
          )
        else
          break
        end
      end
    end
  end
end

M.setup = function ()
  local ns_id = vim.api.nvim_create_namespace("FixMeHighlighting")
  vim.api.nvim_set_hl_ns(ns_id)
  vim.api.nvim_set_hl(ns_id, "FixMe", {
    fg = "#FFFFFF",
    bg = "#FF00EB",
    bold = true
  })

  return ns_id
end

M.attach = function ()
  local cur_buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_attach(cur_buf, true, {
    on_lines = function (_lines, _bufnr, _tick, first_line_num, _orig_last_line, last_line_num)
      M.highlight(cur_buf, vim.bo.filetype, first_line_num, last_line_num)
    end
  })
end

M.hl_ns_id = M.setup()

-- attach edit listener when we enter a buffer or window
vim.api.nvim_create_autocmd(
  {"BufEnter", "BufWinEnter", "WinNew"},
  {
    callback = function()
      M.attach()
    end
  }
)

-- highlight all lines after loading file into buffer
vim.api.nvim_create_autocmd(
  {"BufRead"},
  {
    callback = function()
      local cur_buf = vim.api.nvim_get_current_buf()
      M.highlight(cur_buf, vim.bo.filetype, 0, -1)
    end
  }
)

return M
