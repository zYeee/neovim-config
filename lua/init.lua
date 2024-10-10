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
