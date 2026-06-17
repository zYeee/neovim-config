return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = false, -- toggle on demand with <leader>tb
    current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Gitsigns: " .. desc })
      end

      -- Navigate between hunks
      map("n", "]c", function() gs.nav_hunk("next") end, "next hunk")
      map("n", "[c", function() gs.nav_hunk("prev") end, "previous hunk")

      -- Stage / reset hunks
      map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "stage selection")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "reset selection")
      map("n", "<leader>hS", gs.stage_buffer, "stage buffer")
      map("n", "<leader>hR", gs.reset_buffer, "reset buffer")
      map("n", "<leader>hu", gs.undo_stage_hunk, "undo stage hunk")
      map("n", "<leader>hp", gs.preview_hunk, "preview hunk")

      -- Blame
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "blame line (popup)")
      map("n", "<leader>gB", gs.blame, "blame file (side panel)")
      map("n", "<leader>tb", gs.toggle_current_line_blame, "toggle inline blame")

      -- Diff
      map("n", "<leader>hd", gs.diffthis, "diff this")
      map("n", "<leader>hD", function() gs.diffthis("~") end, "diff against last commit")

      -- Text object: inner hunk (e.g. vih, dih)
      map({ "o", "x" }, "ih", gs.select_hunk, "select hunk")
    end,
  },
}
