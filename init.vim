lua require('init')

let mapleader=";"
set encoding=UTF-8
let g:Lf_ShortcutB = ''

autocmd VimResume * redraw!
autocmd FocusGained,BufEnter * checktime
autocmd BufWritePre *.py :silent call CocAction('runCommand', 'ruff.executeOrganizeImports')
autocmd BufWritePre *.py :silent call CocAction('runCommand', 'ruff.executeFormat')
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree")
      \ && b:NERDTree.isTabTree()) | q | endif


map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <leader><F2> : ls<CR>
map <leader>y "+y
map <leader>p "+p
map <C-g>         : NERDTreeFind<CR>
map <leader><F2>  : NERDTreeToggle<CR>


nmap H gT
nmap L gt
nnoremap <C-f> <cmd>GrugFar<CR>
nmap <silent> <C-]> <Plug>(coc-definition)
nmap <silent> gd <Plug>(coc-definition)
nmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader><leader>t :ToggleTerm direction=float<CR>

vmap <leader>ca <Plug>(coc-codeaction-selected)
vmap <leader>tr :ToggleTermSendVisualLines<CR>


imap jj <Esc><Right>

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <silent> <C-w><C-]> :call CocAction('jumpDefinition', 'split')<CR>
tnoremap <Esc> <C-\><C-n><CR>


set shiftwidth=4
set ts=4
set expandtab
set cursorline
set ignorecase
set cc=120
set backspace=indent,eol,start
set nocompatible              " be iMproved
set noswapfile
set incsearch
set smartcase
set eol

filetype on                   " required!
filetype plugin on
filetype plugin indent on     " required!
syntax on

let g:nerdtree_tabs_open_on_console_startup=1
let g:NERDTreeWinSize = 30

let g:Lf_PreviewInPopup = 1
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }
let g:Lf_ShortcutF = '<C-P>'
let g:Lf_ShowDevIcons = 1
let g:Lf_UseCache = 0

let g:python3_host_prog = '/usr/bin/python3'

command! -nargs=0 Format :call CocActionAsync('format')

command! -nargs=0 OR :call CocActionAsync('runCommand', 'pyright.organizeimports')
