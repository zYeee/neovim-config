local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Redraw after resuming Neovim (e.g. returning from a suspend).
autocmd("VimResume", { group = augroup, command = "redraw!" })

-- Reload files changed outside Neovim when regaining focus.
autocmd({ "FocusGained", "BufEnter" }, { group = augroup, command = "checktime" })

-- (Python format/sort-on-save now lives in lua/config/lsp.lua via the ruff LSP.)
-- (Auto-close-on-last-window is handled by snacks explorer itself.)

-- Open the file explorer on startup (TabNewEntered below doesn't fire for the
-- first tab). Skipped in diff mode (nvim -d / mergetool) where a sidebar is
-- just noise.
autocmd("VimEnter", {
  group = augroup,
  callback = function()
    if vim.o.diff then
      return
    end
    vim.schedule(function()
      local file_win = vim.api.nvim_get_current_win()
      pcall(function()
        Snacks.explorer({
          -- Open the explorer, but keep the cursor on the file/dashboard.
          on_show = function()
            if vim.api.nvim_win_is_valid(file_win) then
              pcall(vim.api.nvim_set_current_win, file_win)
            end
          end,
        })
      end)
    end)
  end,
})

-- Open the file explorer in every newly created tab (but not special UI tabs
-- like diffview, whose buffers aren't normal files).
autocmd("TabNewEntered", {
  group = augroup,
  callback = function()
    vim.schedule(function()
      if vim.bo.buftype ~= "" then
        return
      end
      local file_win = vim.api.nvim_get_current_win()
      pcall(function()
        Snacks.explorer({
          -- Open the explorer, but keep the cursor on the file (not the tree).
          on_show = function()
            if vim.api.nvim_win_is_valid(file_win) then
              pcall(vim.api.nvim_set_current_win, file_win)
            end
          end,
        })
      end)
    end)
  end,
})

-- If closing a window leaves a tab with only the explorer, close that tab too
-- (and land on another tab) rather than stranding the explorer.
autocmd("WinClosed", {
  group = augroup,
  callback = function()
    vim.schedule(function()
      if vim.fn.tabpagenr("$") < 2 then
        return -- never close the last tab
      end
      local has_explorer, has_editable = false, false
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(w) then
          local buf = vim.api.nvim_win_get_buf(w)
          if vim.bo[buf].filetype:match("^snacks_picker") then
            has_explorer = true
          end
          if vim.bo[buf].buftype == "" then
            has_editable = true -- a real editing window remains
          end
        end
      end
      if has_explorer and not has_editable then
        pcall(vim.cmd, "tabclose")
      end
    end)
  end,
})
