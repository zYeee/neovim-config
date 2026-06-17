-- Git diff / review UI: review a commit, range, or branch like a GitHub PR.
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- file-type icons in the panel
  cmd = {
    "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory",
    "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh",
  },
  keys = {
    -- Opens the cmdline prefilled. Press <CR> for working-tree changes, or type
    -- a range first: `main..HEAD` (branch vs main), `HEAD~3` (last 3 commits),
    -- `<sha>^!` (a single commit) — then <CR>.
    { "<leader>dv", function() vim.api.nvim_feedkeys(":DiffviewOpen ", "n", false) end, desc = "Diffview open (range)" },
    { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
    { "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch history" },
    { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
  },
  opts = { enhanced_diff_hl = true },
}
