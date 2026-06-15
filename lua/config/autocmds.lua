local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Redraw after resuming Neovim (e.g. returning from a suspend).
autocmd("VimResume", { group = augroup, command = "redraw!" })

-- Reload files changed outside Neovim when regaining focus.
autocmd({ "FocusGained", "BufEnter" }, { group = augroup, command = "checktime" })

-- Format-on-save for Python via coc + ruff (kept as silent calls so a
-- not-yet-ready coc never spams errors).
autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.py",
  command = "silent call CocAction('runCommand', 'ruff.executeOrganizeImports')",
})
autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.py",
  command = "silent call CocAction('runCommand', 'ruff.executeFormat')",
})

-- Quit Neovim if NERDTree is the last remaining window in the tab.
autocmd("BufEnter", {
  group = augroup,
  command = [[if winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree() | quit | endif]],
})
