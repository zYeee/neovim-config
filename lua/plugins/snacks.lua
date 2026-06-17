-- Lua dashboard (replaces vim-startify) + a couple of passive modules.
-- Must load at startup, hence lazy = false.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Render a file given on the command line before plugins load (faster open).
    quickfile = { enabled = true },
    -- Disable heavy features (treesitter/LSP/etc.) on very large files.
    bigfile = { enabled = true },
    -- Highlight references of the symbol under the cursor (via LSP); jump
    -- between them with ]r / [r.
    words = { enabled = true },
    -- Indent guides + current-scope highlight (handy in Python).
    indent = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        -- Actions wired to the tools this config already ships.
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":Leaderf file" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":Leaderf mru" },
          { icon = " ", key = "g", desc = "Find Text", action = ":GrugFar" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "c", desc = "Config", action = ":edit $MYVIMRC" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  },
  keys = {
    -- Jump between references of the symbol under the cursor. (Not ]]/[[ — those
    -- are taken by Neovim's Python ftplugin for function/class navigation.)
    { "]r", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[r", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference" },
  },
}
