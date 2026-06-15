vim.g.mapleader = ';'

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
      'ellisonleao/gruvbox.nvim',
      name = 'gruvbox',
      lazy = false,
      priority = 1000,
      config = function()
        -- Match the Ghostty "Gruvbox Dark" theme. transparent_mode clears the
        -- editor background so Ghostty's semi-transparent background
        -- (background-opacity 0.9 + background-blur-radius 20) shows through,
        -- giving Neovim the same translucent look as the terminal.
        require('gruvbox').setup({ transparent_mode = true })
        vim.o.background = 'dark'
        vim.cmd.colorscheme('gruvbox')
      end,
    },
    {
        "Yggdroot/LeaderF",          -- The plugin repository
        event = "VimEnter",
        build = ":LeaderfInstallCExtension",  -- Optional: Install the C extension for performance improvement
    },
    {'smoka7/hop.nvim', version = "*", opts = {}},
    {
        "neoclide/coc.nvim",
        branch = "release",  -- Specify the release branch
        event = "VimEnter",  -- Optional: Specify an event for lazy loading
    },
    --{
    --    "jackMort/ChatGPT.nvim",
    --    event = "VeryLazy",
    --    dependencies = {
    --      "MunifTanjim/nui.nvim",
    --      "nvim-lua/plenary.nvim",
    --      "folke/trouble.nvim",
    --      "nvim-telescope/telescope.nvim"
    --    }
    --},
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = { open_mapping = [[<c-\>]] },
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
          { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
          { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
          -- See Configuration section for options
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
    {
        -- In-editor markdown rendering (replaces browser-based markdown-preview).
        -- Recommended to NOT lazy-load; markview manages its own lazy-loading.
        "OXY2DEV/markview.nvim",
        lazy = false,
    },
    {
      "coder/claudecode.nvim",
      config = true,
      opts = {
        auto_start = true,
      },
      cmd = {
        "ClaudeCode",
        "ClaudeCodeFocus",
        "ClaudeCodeAdd",
        "ClaudeCodeSend",
        "ClaudeCodeDiffAccept",
        "ClaudeCodeDiffDeny",
        "ClaudeCodeSelectModel",
      },
      keys = {
        { "<leader>a", nil, desc = "AI/Claude Code" },
        { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
        { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
        { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
        { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
        -- Diff management
        { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
        { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      },
    },
    {
      "MagicDuck/grug-far.nvim",
      cmd = "GrugFar",
      opts = {},
      keys = {
        { "<leader>sr", function() require("grug-far").open() end, desc = "Search & Replace" },
        { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search current word" },
        { "<leader>sr", function() require("grug-far").with_visual_selection() end, mode = "v", desc = "Search selection" },
      },
    },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "nvim-lualine/lualine.nvim", event = "VeryLazy", opts = { options = { theme = "auto" } } },
    -- Tracks the maintained `main` branch (the `master` branch is archived).
    -- main does not support lazy-loading, hence lazy = false.
    { "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate" },
    "mhinz/vim-startify",  -- dashboard: must load at startup
    "ruanyl/vim-gh-line",
    { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, config = true },
    { "kylechui/nvim-surround", event = "VeryLazy", config = true },
    { "mg979/vim-visual-multi", event = "VeryLazy" },
    'scrooloose/nerdtree',       -- opened on startup via nerdtree-tabs; keep eager
    'jistr/vim-nerdtree-tabs',
    { "fatih/vim-go", ft = "go" },
    -- copilot.vim is installed as a CopilotChat dependency above (was duplicated here)
})

local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', '<leader><leader>w', function()
  hop.hint_words({ direction = directions.AFTER_CURSOR}) end, {remap=true})
vim.keymap.set('', '<leader><leader>b', function()
  hop.hint_words({ direction = directions.BEFORE_CURSOR}) end, {remap=true})

-- Plugin setup() calls now live in their lazy specs above (config = true / opts).
-- nvim-treesitter `main` API (the legacy `nvim-treesitter.configs` setup with
-- `auto_install`/`highlight.enable` only existed on the archived `master` branch).
-- setup{} is optional but pins the install dir; install() is async and a no-op
-- for parsers that are already installed.
require('nvim-treesitter').setup {}
require('nvim-treesitter').install {
  'python', 'go', 'lua', 'markdown', 'markdown_inline', 'json', 'yaml', 'bash',
}

-- The bash parser also highlights `sh`-filetype shell scripts.
vim.treesitter.language.register('bash', 'sh')

-- Highlighting is no longer enabled automatically on `main`; start it per buffer.
-- pcall guards the first launch, where install() may still be running async and
-- the parser is not yet on the runtimepath. (markdown_inline has no standalone
-- filetype — it is injected into markdown buffers, which markview relies on.)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'go', 'lua', 'markdown', 'json', 'yaml', 'sh', 'bash' },
  callback = function() pcall(vim.treesitter.start) end,
})
