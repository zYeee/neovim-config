return {
  "akinsho/toggleterm.nvim",
  version = "*",
  -- Kept eager so the <c-\> open_mapping is registered at startup.
  config = function()
    require("toggleterm").setup({ open_mapping = [[<c-\>]] })
    vim.keymap.set("n", "<leader><leader>t", "<cmd>ToggleTerm direction=float<cr>", { desc = "Floating terminal" })
    vim.keymap.set("v", "<leader>tr", "<cmd>ToggleTermSendVisualLines<cr>", { desc = "Send selection to terminal" })
  end,
}
