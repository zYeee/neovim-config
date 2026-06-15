return {
  "smoka7/hop.nvim",
  version = "*",
  opts = {},
  keys = {
    {
      "<leader><leader>w",
      function()
        require("hop").hint_words({ direction = require("hop.hint").HintDirection.AFTER_CURSOR })
      end,
      mode = "",
      desc = "Hop to word after cursor",
    },
    {
      "<leader><leader>b",
      function()
        require("hop").hint_words({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR })
      end,
      mode = "",
      desc = "Hop to word before cursor",
    },
  },
}
