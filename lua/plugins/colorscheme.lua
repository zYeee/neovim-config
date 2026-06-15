return {
  "ellisonleao/gruvbox.nvim",
  name = "gruvbox",
  lazy = false,
  priority = 1000,
  config = function()
    -- Match the Ghostty "Gruvbox Dark" theme. transparent_mode clears the
    -- editor background so Ghostty's semi-transparent background
    -- (background-opacity 0.9 + background-blur-radius 20) shows through,
    -- giving Neovim the same translucent look as the terminal.
    require("gruvbox").setup({ transparent_mode = true })
    vim.o.background = "dark"
    vim.cmd.colorscheme("gruvbox")
  end,
}
