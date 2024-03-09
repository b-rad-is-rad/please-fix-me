local M = {}

M.setup = function ()
  local ns_id = vim.api.nvim_create_namespace("FixMeHighlighting")
  vim.api.nvim_set_hl_ns(ns_id)
  vim.api.nvim_set_hl(ns_id, "FixMe", {
    fg = "#000000",
    bg = "#ffffff"
  })

  return ns_id
end
-- FIXMEEEEEEEEEE FIXME
-- FIXMEEEE
--
--

M.attach = function (hl_ns_id)
  local cur_buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_attach(cur_buf, true, {
    on_lines = function (_lines, _bufnr, _tick, first_line, _orig_last_line, last_line)
      local lines = vim.api.nvim_buf_get_lines(cur_buf, first_line, last_line, false)

      for i, line in ipairs(lines) do
        local word_start, word_end = string.find(line, "FIXME")

        if word_start then
          vim.print(line)
          vim.api.nvim_buf_add_highlight(cur_buf, hl_ns_id, "FixMe", first_line + i - 1, 0, -1)
        end
      end
    end
  })
end

vim.api.nvim_create_autocmd(
  {"BufEnter", "BufWinEnter", "WinNew"},
  {
    callback = function()
      local ns_id = M.setup()
      M.attach(ns_id)
    end
  }
)

return M
