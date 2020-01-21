set exrc
set secure

" ------------------------------------------------------------------------------
" Attemt to load project configuration.

if filereadable("init.vim") && expand("%:p:h") !=? getcwd()
	echo "Project loaded"
	so init.vim
endif

" ------------------------------------------------------------------------------
" OS detection

	if !exists("g:os")
		if has("win64") || has("win32") || has("win16")
			let g:os = "Windows"
		else
			let g:os = substitute(system('uname'), '\n', '', '')
		endif
	endif

	if g:os == "Windows"
		" Unmap this as it hangs the terminal on windows.
		nmap <C-z> <Nop>
	endif

" ------------------------------------------------------------------------------
" Path configuration 

	" Local path
	let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

	" Setup path to external tools
	let $PATH .= ";" . s:path . "/tools/ctags/"
	let $PATH .= ";" . s:path . "/tools/fd/"

" ------------------------------------------------------------------------------
" Plugins 
	call plug#begin(s:path . '/plugged')

		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
		Plug 'morhetz/gruvbox'
		Plug 'junegunn/fzf'
		Plug 'junegunn/fzf.vim'
		Plug 'fszymanski/fzf-quickfix'
		Plug 'tpope/vim-surround'
		Plug 'tpope/vim-fugitive'
		Plug 'tpope/vim-commentary'
		" Highlights yanked selection.
		Plug 'machakann/vim-highlightedyank'
		" Automatic quote/braces completion plugin.
		" Plug 'jiangmiao/auto-pairs'

		" This could be a nice replacement for the :Explore
		" Plug 'vifm/vifm.vim'

		" ncm2 and dependencies
		Plug 'roxma/nvim-yarp'
		Plug 'ncm2/ncm2'
		Plug 'ncm2/ncm2-bufword'
		Plug 'ncm2/ncm2-path'

		" vim lsp and dependencies.
		Plug 'prabirshrestha/async.vim'
		Plug 'prabirshrestha/vim-lsp'
		Plug 'ncm2/ncm2-vim-lsp'
	call plug#end()

" ------------------------------------------------------------------------------
" ncm2 

	" enable ncm2 for all buffers
	autocmd BufEnter * call ncm2#enable_for_buffer()

	" let g:lsp_log_verbose = 1
	" let g:lsp_log_file = 'vim-lsp.log'	" vim-lsp

	" enable for include debug when something gets odd...
	let g:lsp_diagnostics_enabled = 0
	let g:lsp_highlight_references_enabled = 1

	if executable('pyls')
		" pip install python-language-server
		" au User lsp_setup call lsp#register_server({
		" 			\ 'name': 'pyls',
		" 			\ 'cmd': {server_info->['pyls']},
		" 			\ 'whitelist': ['python'],
		" 			\ })

		au User lsp_setup call lsp#register_server({
					\ 'name': 'clangd',
					\ 'cmd': {server_info->['clangd', '--background-index']},
					\ 'whitelist': ['cpp', 'c', 'h', 'hpp'],
					\ })
	endif

	function! s:on_lsp_buffer_enabled() abort
		setlocal omnifunc=lsp#complete
		setlocal signcolumn=yes
		nmap <buffer> gd <plug>(lsp-definition)
		nmap <buffer> <f2> <plug>(lsp-rename)
		" refer to doc to add more commands
	endfunction

	augroup lsp_install
		au!
		" call s:on_lsp_buffer_enabled only for languages that has the server registered.
		autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
	augroup END

	nnoremap <Leader>d :LspDefinition<CR>
	nnoremap <Leader>r :LspReferences<CR>

" ------------------------------------------------------------------------------
" Bindings 

	let mapleader="\ "

	" maybe use the switchbuf=useopen??
	nnoremap <Leader>v :e $MYVIMRC<cr>

	let s:last_switch_op = "buf"
	let s:last_buf = ""
	let s:last_win = ""
	aug smart_switch
		au!

		" title?
		" todo: catch the window close and then fallback to buffer mode.
		" todo: catch the windows temp windows like fzf... and make them noop.
		au WinEnter * if &ft != 'fzf' | let s:last_switch_op = "win" | let s:last_win = winnr("#") | endif
		au BufWinLeave * if &ft != 'fzf' | let s:last_switch_op = "buff" | let s:last_buf = bufnr("#") | endif
		" aut WinEnter * echo &ft
	aug END

	" Switches to the last buffer or window. Depends on what was the last switch
	" OP.
	func! SwitchBufOrWin()
		if s:last_switch_op =~ "buf"
			if s:last_buf != ""
				" :b &s:last_buf
				execute ':b ' . s:last_buf
				execute ':echo ' . s:last_buf
			endif
		elseif s:last_switch_op =~ "win"
			if s:last_win != ""
				execute ':echo ' . s:last_buf
				:exe s:last_win . "wincmd w"
			endif
		endif
	endfunc

	" nnoremap <silent> <tab> :call SwitchBufOrWin()<cr>
	nnoremap <tab> :call SwitchBufOrWin()<cr>

	" Fold jumping with alt key.
	nnoremap <M-j> zj
	nnoremap <M-k> zk

	" Snippets
	nmap <Leader>-- o<esc>0D2a/<esc>77a-<esc>
	nmap <Leader>head <Leader>--2o<esc>75a-<esc>kA<Tab>

	" FZF fuzzy finder binding.
	
	" [Buffers] Jump to the existing window if possible
	let g:fzf_buffers_jump = 1 

	command! -bang -nargs=* Rg
				\ call fzf#vim#grep(
				\   'rg --column --line-number --no-heading --color=always' . 
				\   ' --smart-case --follow '.shellescape(<q-args>), 1,<bang>0)

	nnoremap <Leader>p :Files .<CR> 
	nnoremap <Leader>b :Buffers .<CR> 
	nnoremap <Leader>t :BTags<CR>
	nnoremap <Leader>R :Rg <c-r>=expand("<cword>")<cr>
	nnoremap <Leader>s :LspWorkspaceSymbol<cr>
	nnoremap <Leader>m :LspDocumentSymbol<cr>:sleep 50ms<cr>:ccl<cr>:Quickfix<cr>

	" python clang format.
	" map·<C-I>·:pyf ../clang-format.py<cr>
	" imap·<C-I>·<c-o>:pyf·<path-to-this-file>/clang-format.py<cr>

	let s:last_fold_level = 1
	func! FoldToLevel()
		set foldenable
		if v:count != 0
			let s:last_fold_level = v:count
		endif

		let &foldlevel = s:last_fold_level
	endfunc

	nnoremap <Leader>f :call FoldToLevel()<cr>

	command! -nargs=* -bang Ag call fzf#vim#ag_raw('-f --ignore-dir={.git,.svn} ' . <q-args> . ' .')

	" Use <TAB> to select the popup menu:
	inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

	" Prevent the new line after completion menu Enter:
	inoremap <expr> <CR> (pumvisible() ? "\<c-y>\ " : "\<CR>")

	" Terminal binding to escape from the insert mode.
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

" ------------------------------------------------------------------------------
" ctags settings 

	" Common ctags command.
	" let ctags_cmd = 
	" 			\"!ctags.exe -R --c++-kinds=+p --fields=+iaS --extras=+q ".
	" 			\"--exclude=.git --exclude=.svn --exclude=extern --verbose=yes"

	" Rebuild tags for the whole project.
	" nmap <Leader>rt :exec ctags_cmd . " ./Enfusion" \| :exec ctags_cmd . " -a ./A4Gamecode"

	" Auto update ctags on file save.
	" aug ctags_save_hook
	" 	" Clear group.
	" 	au!
		
	" 	" Update ctags for modified file.
	" 	au BufWritePost *.h,*.cpp,*hpp,*.c
	" 				\silent exec ctags_cmd . " -a " . expand("%") | 
	" 				\echo "Tags updated: " . expand("%")
	" aug END

" ------------------------------------------------------------------------------
" FZF Settings 

	" function! PlaceFileName()
	" 	let fileName = expand("%:t:r")
	" 	exec "Files ." . fileName
	" endfunction

	" nmap <Leader>o :execute PlaceFileName()<CR>

" ------------------------------------------------------------------------------
" Buffer autocommands.

	aug config_save_hook
		" Clear the group.
		au!

		" Auto reload any .vim configuration and output its name.
		au BufWritePost *.vim so % | echo "Config reloaded: " . expand("%")
	aug END

	aug file_hooks
		au!

		au FocusGained,BufEnter * :silent! checktime
		au FocusLost,WinLeave * :silent! w
		au FileType c,cpp,cs,java set commentstring=//\ %s
		au CursorHold * checktime
	aug END

" ------------------------------------------------------------------------------
" Basic settings.

	" IMPORTANT: :help Ncm2PopupOpen for more information
	set completeopt=noinsert,menuone,noselect

	set cmdheight=2
	set updatetime=300
	set shortmess+=c
	set signcolumn=yes

	language en
	set cursorline
	set autowriteall autoread
	set langmenu=en_US.UTF-8
	set foldmethod=syntax nofen foldopen-=block,hor
	set splitbelow splitright
	set number relativenumber
	set shiftwidth=2 ts=2
	set scrolloff=5
	set list listchars=space:·,tab:→\ 
	set ignorecase smartcase
	colorscheme gruvbox

	" Highlight as error everything above 100 column.
 	match Error '/\%100v.\+/'
