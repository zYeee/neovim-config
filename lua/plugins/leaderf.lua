return {
  "Yggdroot/LeaderF",
  event = "VimEnter",
  build = ":LeaderfInstallCExtension", -- C extension for performance
  init = function()
    vim.g.Lf_ShortcutB = ""
    vim.g.Lf_ShortcutF = "<C-P>"
    vim.g.Lf_PreviewInPopup = 1
    vim.g.Lf_WindowPosition = "popup"
    vim.g.Lf_PreviewResult = { Function = 0, BufTag = 0 }
    vim.g.Lf_ShowDevIcons = 1
    vim.g.Lf_UseCache = 0
  end,
}
