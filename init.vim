" ^..^ ___________ ^..^
" OS detection

	if !exists("g:os")
		if has("win64") || has("win32") || has("win16")
			let g:os = "Windows"
		else
			let g:os = substitute(system('uname'), '\n', '', '')
		endif
	endif

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
		Plug 'junegunn/fzf'
		Plug 'junegunn/fzf.vim'
		Plug 'tpope/vim-surround'
		Plug 'tpope/vim-fugitive'
		Plug 'tpope/vim-commentary'

		" ncm2 and dependencies
		Plug 'roxma/nvim-yarp'
		Plug 'ncm2/ncm2'
		Plug 'ncm2/ncm2-bufword'
		Plug 'ncm2/ncm2-path'
		" ncm2 clang service
		Plug 'ncm2/ncm2-pyclang'
		call plug#end()

" == ncm2 ==

	" enable ncm2 for all buffers
	autocmd BufEnter * call ncm2#enable_for_buffer()

	" IMPORTANT: :help Ncm2PopupOpen for more information
	set completeopt=noinsert,menuone,noselect

	" ncm2-pyclang settings
	" if the libclang was not found, use this to specify the correct path:
	"	g:ncm2_pyclang#library_path=...
	
	" Project settings:
	" 1) Compilation database
	" 	 CMake settings to generate such file -> -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	"
	" let g:ncm2_pyclang#database_path = [
	" 			\ 'compile_commands.json',
	" 			\ 'build/compile_commands.json'
	" 			\ ]

	" Goto declaration
	autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>

" == Bindings ==

	" FZF fuzzy finder binding.
	nmap <C-p> :Files .<Enter> 

	" Terminal binding to epscape from the insert mode.
	" Note: Breaks return from FZF menu.
	"	tnoremap <Esc> <C-\><C-n>

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

	" Auto update ctags on file save.
	aug ctags_save_hook
		" Clear group.
		au!
		
		" Update ctags for modified file.
		au BufWritePost *.h,*.cpp,*hpp,*.c
					\silent exec ctags_cmd . " -a " . expand("%") | 
					\echo "Tags updated: " . expand("%")
	aug END

" == FZF Settings ==

	" function! PlaceFileName()
	" 	let fileName = expand("%:t:r")
	" 	exec "Files ." . fileName
	" endfunction

	" nmap <Leader>o :execute PlaceFileName()<CR>

" == Auto config reload ==

	aug config_save_hook
		" Clear the group.
		au!

		" Auto reload any .vim configuration and output its name.
		au BufWritePost *.vim so % | echo "Config reloaded: " . expand("%")
	aug END

" == Save on buffer leave ==

"	aug buff_save_hook
"		au!
"
"		" if not readonly save the buffer.
"		au FocusLost,BufLeave * if (&ro == 0) | w | endif
"	aug END

" == Leader ==

	let mapleader="\ "

" == Language ==

	set langmenu=en_US.UTF-8
	language en

" == Folding ==

	set foldmethod=syntax
	set nofen

" == Windows and splits ==
	set splitbelow
	set splitright

" == Line numbering ==

	set number
	set relativenumber

" == Whitespace configuration ==

	set ts=2
	set shiftwidth=2
	set list
	set listchars=space:·,tab:→\ 

	" Highlight as error everything above 100 column.
 	match Error '/\%100v.\+/'

" == Color Scheme ==

	colorscheme gruvbox
