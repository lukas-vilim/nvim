" == Bindings ==

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

inoremap <C-l> <Right>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>

" == Settings ==
set number
set relativenumber

