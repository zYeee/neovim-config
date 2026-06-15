return {
  "neoclide/coc.nvim",
  branch = "release",
  event = "VimEnter",
  config = function()
    local map = vim.keymap.set

    -- Go-to-definition (<Plug> mappings must stay recursive).
    map("n", "<C-]>", "<Plug>(coc-definition)", { silent = true, remap = true })
    map("n", "gd", "<Plug>(coc-definition)", { silent = true, remap = true })
    -- Code actions on the selection (normal + visual).
    map({ "n", "v" }, "<leader>ca", "<Plug>(coc-codeaction-selected)", { remap = true })
    -- Jump to definition in a split.
    map("n", "<C-w><C-]>", function()
      vim.fn.CocAction("jumpDefinition", "split")
    end, { silent = true })

    vim.api.nvim_create_user_command("Format", function()
      vim.fn.CocActionAsync("format")
    end, { nargs = 0 })
    vim.api.nvim_create_user_command("OR", function()
      vim.fn.CocActionAsync("runCommand", "pyright.organizeimports")
    end, { nargs = 0 })
  end,
}
