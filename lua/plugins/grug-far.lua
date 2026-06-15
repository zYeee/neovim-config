return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = {},
  keys = {
    { "<C-f>", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search & Replace (word under cursor)" },
    { "<C-f>", function() require("grug-far").with_visual_selection() end, mode = "v", desc = "Search & Replace (selection)" },
    { "<leader>sr", function() require("grug-far").open() end, desc = "Search & Replace" },
    { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search current word" },
    { "<leader>sr", function() require("grug-far").with_visual_selection() end, mode = "v", desc = "Search selection" },
  },
}
