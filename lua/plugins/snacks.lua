-- Lua dashboard (replaces vim-startify). Only the dashboard module is enabled;
-- the rest of snacks stays off. Must load at startup, hence lazy = false.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
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
}
