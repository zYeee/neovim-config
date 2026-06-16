-- Motion plugin (replaces hop.nvim): search-based jump + treesitter / remote ops.
return {
  "folke/flash.nvim",
  -- Load eagerly so the `/`-search labelling hook is installed at startup
  -- (not only after the first flash keymap is used).
  event = "VeryLazy",
  opts = {
    modes = {
      -- Leave f/F/t/T as vanilla, closest to the old hop behavior.
      char = { enabled = false },
      -- Label `/` and `?` matches so you can jump to any match by its label.
      search = { enabled = true },
    },
  },
  keys = {
    -- Preserved hop bindings: jump to a word forward / backward.
    {
      "<leader><leader>w",
      function() require("flash").jump({ search = { forward = true, wrap = false } }) end,
      mode = "",
      desc = "Flash forward",
    },
    {
      "<leader><leader>b",
      function() require("flash").jump({ search = { forward = false, wrap = false } }) end,
      mode = "",
      desc = "Flash backward",
    },
    -- New: jump/select by treesitter node. Own key (`;;s`) to avoid clashing
    -- with nvim-surround's visual `S`.
    {
      "<leader><leader>s",
      function() require("flash").treesitter() end,
      mode = { "n", "x", "o" },
      desc = "Flash Treesitter",
    },
    -- New: remote operations — e.g. `yr` then jump elsewhere, grab a textobject,
    -- and return. Operator-pending only, so normal-mode `r` (replace) is untouched.
    {
      "r",
      function() require("flash").remote() end,
      mode = "o",
      desc = "Remote Flash",
    },
  },
}
