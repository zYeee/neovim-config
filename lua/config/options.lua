-- Leader must be set before lazy.nvim loads any plugin `keys` specs.
vim.g.mapleader = ";"

local opt = vim.opt

opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = true
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true
opt.colorcolumn = "120"
opt.backspace = { "indent", "eol", "start" }
opt.swapfile = false
opt.incsearch = true
opt.endofline = true
