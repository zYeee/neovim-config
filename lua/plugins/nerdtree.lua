return {
  {
    "scrooloose/nerdtree", -- opened on startup via nerdtree-tabs; keep eager
    lazy = false,
    init = function()
      vim.g.nerdtree_tabs_open_on_console_startup = 1
      vim.g.NERDTreeWinSize = 30
    end,
    config = function()
      vim.keymap.set("", "<C-g>", "<cmd>NERDTreeFind<cr>", { desc = "Find current file in NERDTree" })
      vim.keymap.set("", "<leader><F2>", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle NERDTree" })
    end,
  },
  { "jistr/vim-nerdtree-tabs", lazy = false },
}
