-- Keymap discoverability: press a prefix (e.g. the `;` leader) and pause to see
-- every binding under it, labelled by its `desc`.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    -- Group labels for the leader namespaces this config uses.
    spec = {
      { "<leader>a", group = "AI / Claude" },
      { "<leader>h", group = "git hunks" },
      { "<leader>d", group = "diff / review" },
      { "<leader>s", group = "search / replace" },
      { "<leader>t", group = "toggle" },
      { "<leader>g", group = "git / GitHub" },
      { "<leader><leader>", group = "flash" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps (which-key)",
    },
  },
}
