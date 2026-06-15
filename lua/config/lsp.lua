-- Native LSP setup. Currently just gopls (replaces vim-go); Python still goes
-- through coc, so this only attaches to Go buffers.

-- gopls server config. On Neovim 0.11+ this needs no nvim-lspconfig.
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
})

-- Guard on the binary so opening a Go file without a Go toolchain installed
-- doesn't spam "cmd failed" errors.
if vim.fn.executable("gopls") == 1 then
  vim.lsp.enable("gopls")
end

-- Buffer-local keymaps + completion whenever an LSP attaches.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Mirror the coc keymaps so Go buffers feel identical to Python ones.
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
    map("n", "<C-]>", vim.lsp.buf.definition, "LSP: go to definition")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")

    -- Native autocompletion popup (parity with coc's completion).
    pcall(function()
      if client and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      end
    end)
  end,
})

-- Format + organize imports on save for Go (replaces vim-go's gofmt autosave).
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("user_go_format", { clear = true }),
  pattern = "*.go",
  callback = function(args)
    local bufnr = args.buf
    if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) == 0 then
      return -- no LSP attached (e.g. gopls not installed) — nothing to do
    end
    -- organize imports
    pcall(function()
      local params = vim.lsp.util.make_range_params(0, "utf-8")
      params.context = { only = { "source.organizeImports" } }
      local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
      for _, res in pairs(results or {}) do
        for _, action in pairs(res.result or {}) do
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
          end
        end
      end
    end)
    -- gofmt-equivalent formatting via gopls
    pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false })
  end,
})
