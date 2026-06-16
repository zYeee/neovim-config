return {
  -- Tracks the maintained `main` branch (the `master` branch is archived).
  -- main does not support lazy-loading, hence lazy = false.
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- main API: setup{} is optional but pins the install dir; install() is
    -- async and a no-op for parsers that are already installed.
    require("nvim-treesitter").setup({})
    -- `vim` is installed so vimscript injected into Lua (e.g. vim.cmd("…"))
    -- uses nvim-treesitter's parser+query, not Neovim's bundled pair which
    -- currently drift on nightly (query references a `tab` node the parser lacks).
    require("nvim-treesitter").install({
      "python", "go", "lua", "markdown", "markdown_inline", "json", "yaml", "bash", "vim",
    })

    -- The bash parser also highlights `sh`-filetype shell scripts.
    vim.treesitter.language.register("bash", "sh")

    -- Highlighting is no longer enabled automatically on `main`; start it per
    -- buffer. pcall guards the first launch, where install() may still be
    -- running async and the parser is not yet on the runtimepath.
    -- (markdown_inline has no standalone filetype — it is injected into
    -- markdown buffers, which markview relies on.)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "go", "lua", "markdown", "json", "yaml", "sh", "bash", "vim" },
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
