" == Path configuration ==
	" Local path
	let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

	" Setup path to external tools
	let $PATH .= ";" . s:path . "/tools/ctags/"
	let $PATH .= ";" . s:path . "/tools/fd/"

" == Plugins ==
	call plug#begin(s:path . '/plugged')
		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
		Plug 'morhetz/gruvbox'
		Plug 'junegunn/fzf', { 'do': './install --all' }
		Plug 'junegunn/fzf.vim'
	call plug#end()

" == Bindings ==

	" FZF fuzzy finder binding.
	nmap <C-p> :Files .<Enter> 

	" Terminal binding to epscape from the insert mode.
	tnoremap <Esc> <C-\><C-n>

	" Remove normal mode arrow keys.
	nmap <Up> <Nop>
	nmap <Down> <Nop>
	nmap <Left> <Nop>
	nmap <Right> <Nop>

	" Remap the insert mode movement keys.
	imap <Up> <Nop>
	imap <Down> <Nop>
	imap <Left> <Nop>
	imap <Right> <Nop>

	inoremap <C-l> <Right>
	inoremap <C-j> <Down>
	inoremap <C-k> <Up>

" == ctags settings ==
	" Common ctags command.
	let ctags_cmd = 
				\"!ctags.exe -R --c++-kinds=+p --fields=+iaS --extras=+q ".
				\"--exclude=.git --exclude=.svn --exclude=extern --verbose=yes"

	" Rebuild tags for the whole project.
	nmap <Leader>rt :exec ctags_cmd . " ./Enfusion" \| :exec ctags_cmd . " -a ./A4Gamecode"

" == FZF Settings ==
" function! PlaceFileName()
" 	let fileName = expand("%:t:r")
" 	exec "Files ." . fileName
" endfunction

" nmap <Leader>o :execute PlaceFileName()<CR>

aug main_rc
	" Clear the group.
	au!

	" Auto reload any .vim configuration and output its name.
	au BufWritePost *.vim so % | echo "Config reloaded: " . expand("%")
	
	" Update ctags for modified file.
	au BufWritePost *.h,*.cpp silent exec ctags_cmd . " -a " . expand("%") | echo "Tags updated: " . expand("%")
aug END

" == Settings ==
let mapleader="\ "

" == Folding ==
set foldmethod=syntax
set nofen

" == Line numbering ==
set number
set relativenumber

" == Whitespace configuration ==
set ts=2
set shiftwidth=2
set list
set listchars=space:·,tab:→\ 

" == Color Scheme ==
colorscheme gruvbox
