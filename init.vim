" == Common ==
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" == Bindings ==
nmap <C-p> :Files .<Enter> 

" Remove normal mode arrow keys.
nmap <Up> <Nop>
nmap <Down> <Nop>
nmap <Left> <Nop>
nmap <Right> <Nop>

" Remove insert mode arrow keys.
imap <Up> <Nop>
imap <Down> <Nop>
imap <Left> <Nop>
imap <Right> <Nop>

" inoremap <C-l> <Right>
" inoremap <C-h> <Left>
" inoremap <C-j> <Down>
" inoremap <C-k> <Up>
" map <BS> <C-l><Del>

" == Settings ==
set number
set relativenumber

set ts=2
set shiftwidth=2

set list
set listchars=space:·,tab:→\ 

" == Plugins ==
call plug#begin(s:path . '/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
call plug#end()

" == Color Scheme ==
colorscheme gruvbox
