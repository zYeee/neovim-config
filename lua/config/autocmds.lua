local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Redraw after resuming Neovim (e.g. returning from a suspend).
autocmd("VimResume", { group = augroup, command = "redraw!" })

-- Reload files changed outside Neovim when regaining focus.
autocmd({ "FocusGained", "BufEnter" }, { group = augroup, command = "checktime" })

-- (Python format/sort-on-save now lives in lua/config/lsp.lua via the ruff LSP.)

-- Quit Neovim if NERDTree is the last remaining window in the tab.
autocmd("BufEnter", {
  group = augroup,
  command = [[if winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree() | quit | endif]],
})
