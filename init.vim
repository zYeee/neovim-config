lua require('init')

let g:Lf_ShortcutB = ''

autocmd VimResume * redraw!
autocmd FocusGained,BufEnter * checktime
autocmd BufWritePre *.py :silent call CocAction('runCommand', 'ruff.executeOrganizeImports')
autocmd BufWritePre *.py :silent call CocAction('runCommand', 'ruff.executeFormat')
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree")
      \ && b:NERDTree.isTabTree()) | q | endif


noremap <c-h> <c-w>h
noremap <c-j> <c-w>j
noremap <c-k> <c-w>k
noremap <c-l> <c-w>l
noremap <leader>ls : ls<CR>
noremap <leader>y "+y
noremap <leader>p "+p
noremap <C-g>         : NERDTreeFind<CR>
noremap <leader><F2>  : NERDTreeToggle<CR>


nnoremap H gT
nnoremap L gt
nnoremap <C-f> <cmd>GrugFar<CR>
nmap <silent> <C-]> <Plug>(coc-definition)
nmap <silent> gd <Plug>(coc-definition)
nmap <leader>ca <Plug>(coc-codeaction-selected)
nnoremap <leader><leader>t :ToggleTerm direction=float<CR>

vmap <leader>ca <Plug>(coc-codeaction-selected)
vnoremap <leader>tr :ToggleTermSendVisualLines<CR>


inoremap jj <Esc><Right>

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <silent> <C-w><C-]> :call CocAction('jumpDefinition', 'split')<CR>
tnoremap <Esc> <C-\><C-n>


set shiftwidth=4
set ts=4
set expandtab
set cursorline
set ignorecase
set cc=120
set backspace=indent,eol,start
set noswapfile
set incsearch
set smartcase
set eol

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
