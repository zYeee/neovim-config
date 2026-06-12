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
      'sainnhe/sonokai',
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.sonokai_enable_italic = true
        vim.cmd.colorscheme('sonokai')
      end
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
    { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate" },
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
-- Treesitter keeps its setup here so it loads eagerly for highlighting.
pcall(function()
    require('nvim-treesitter.configs').setup {
        auto_install = true,
        highlight = {
            enable = true,
        },
    }
end)
