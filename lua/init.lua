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
    {
        "davidhalter/jedi-vim",
        ft = "python",
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
        config = true
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
        "Carus11/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
          vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
      "coder/claudecode.nvim",
      dependencies = { "folke/snacks.nvim" },
      config = true,
      opts = {
        auto_start = true,
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
    "dyng/ctrlsf.vim",
    "windwp/nvim-autopairs",
    "nvim-lualine/lualine.nvim",
    "nvim-treesitter/nvim-treesitter",
    "mhinz/vim-startify",
    "github/copilot.vim",
    "ruanyl/vim-gh-line",
    "lewis6991/gitsigns.nvim",
    "kylechui/nvim-surround",
    "mg979/vim-visual-multi",
    'scrooloose/nerdtree',
    'jistr/vim-nerdtree-tabs',
    'fatih/vim-go'
})

local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', '<leader><leader>w', function()
  hop.hint_words({ direction = directions.AFTER_CURSOR}) end, {remap=true})
vim.keymap.set('', '<leader><leader>b', function()
  hop.hint_words({ direction = directions.BEFORE_CURSOR}) end, {remap=tru})

-- require("chatgpt").setup {}
require("toggleterm").setup{
  open_mapping = [[<c-\>]],
}

require("nvim-autopairs").setup {}
require('gitsigns').setup {}
require("nvim-surround").setup {}
require('lualine').setup {options = {theme = 'auto' }}
require('nvim-treesitter.configs').setup {
    auto_install = true,
    highlight = {
        enable = true,
    },
}
