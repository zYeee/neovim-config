-- Native LSP (replaces coc.nvim). Servers:
--   pyright    – Python types, definitions, hover, completion
--   ruff       – Python lint, format, import sorting (`ruff server`)
--   gopls      – Go
--   typos_lsp  – spell-checking (misspellings shown as diagnostics)
-- Completion UI is provided by blink.cmp.

-- Show diagnostics inline (typos' misspellings, pyright/ruff errors, etc.).
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  severity_sort = true,
})

-- Advertise blink.cmp's completion capabilities to every server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = capabilities })

-- Resolve the project's Python interpreter so pyright can see third-party
-- packages (coc-pyright did this automatically; plain pyright does not).
local function detect_python_path(root)
  root = root or vim.fn.getcwd()
  -- 1. An already-activated virtualenv.
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
  end
  -- 2. A project-local venv (uv / poetry / python -m venv all use these).
  for _, name in ipairs({ ".venv", "venv" }) do
    local py = vim.fs.joinpath(root, name, "bin", "python")
    if vim.uv.fs_stat(py) then
      return py
    end
  end
  return nil
end

-- Servers -------------------------------------------------------------------
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
  settings = {
    -- Type-check only open files (matches the old coc-settings choice).
    python = { analysis = { diagnosticMode = "openFilesOnly" } },
  },
  before_init = function(_, config)
    local py = detect_python_path(config.root_dir)
    if py then
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = py
    end
  end,
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  init_options = {
    -- Enable the import-sorting rule (I001) so a single fix-all on save both
    -- removes unused imports and sorts them.
    settings = { lint = { extendSelect = { "I" } } },
  },
})

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
})

vim.lsp.config("typos_lsp", {
  cmd = { "typos-lsp" },
  filetypes = { "python", "go", "lua", "markdown", "json", "yaml", "sh", "bash", "gitcommit", "text" },
  root_markers = { "_typos.toml", ".typos.toml", ".git" },
})

-- Enable only the servers whose binary is actually installed.
for name, bin in pairs({
  pyright = "pyright-langserver",
  ruff = "ruff",
  gopls = "gopls",
  typos_lsp = "typos-lsp",
}) do
  if vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

-- Buffer-local keymaps on attach (capability-gated so a server only claims the
-- keys it can actually serve — e.g. ruff has code actions but no definition).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    local bufnr = args.buf
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
    end

    if client:supports_method("textDocument/definition") then
      map("n", "gd", vim.lsp.buf.definition, "go to definition")
      map("n", "<C-]>", vim.lsp.buf.definition, "go to definition")
      -- Definition in a split (jump back with <C-o>).
      map("n", "<C-w><C-]>", function()
        vim.cmd("split")
        vim.lsp.buf.definition()
      end, "definition in split")
    end
    if client:supports_method("textDocument/codeAction") then
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "code action")
    end
  end,
})

-- Synchronously apply `source.*` code actions (organize imports, fix-all) from
-- every attached server that offers them. Used on save; guarded so a failure
-- never blocks `:w`.
local function apply_source_actions(bufnr, kinds)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/codeAction" })) do
    pcall(function()
      local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
      params.context = { only = kinds, diagnostics = {} }
      local resp = client:request_sync("textDocument/codeAction", params, 2000, bufnr)
      for _, action in ipairs((resp or {}).result or {}) do
        -- ruff (and others) return actions with no inline edit; resolve first.
        if not action.edit and not action.command then
          local resolved = client:request_sync("codeAction/resolve", action, 2000, bufnr)
          action = (resolved or {}).result or action
        end
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        elseif action.command then
          client:exec_cmd(action.command, { bufnr = bufnr })
        end
      end
    end)
  end
end

-- Format + organize imports on save (Python via ruff, Go via gopls).
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("user_lsp_format", { clear = true }),
  pattern = { "*.py", "*.go" },
  callback = function(args)
    local bufnr = args.buf
    if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
      return -- no server attached (e.g. binary not installed)
    end
    local ft = vim.bo[bufnr].filetype
    if ft == "python" then
      -- ruff fix-all sorts imports (I001) + removes unused, in one edit.
      apply_source_actions(bufnr, { "source.fixAll.ruff" })
    elseif ft == "go" then
      apply_source_actions(bufnr, { "source.organizeImports" })
    end
    pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false })
  end,
})

-- Manual commands (parity with the old coc :Format / :OR).
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = false })
end, { nargs = 0 })
vim.api.nvim_create_user_command("OR", function()
  apply_source_actions(vim.api.nvim_get_current_buf(), { "source.organizeImports", "source.organizeImports.ruff" })
end, { nargs = 0 })
