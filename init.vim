set exrc
set secure
let mapleader="\ "

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
		Plug 'tpope/vim-dispatch'

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
"  clang format
	func! ClangFmt()
		let current_line = line('.')
		let l:lines = string(current_line).':'.string(current_line + v:count)
		exec 'pyf ' . s:path . '\tools\clang\clang-format.py'
	endfunc

	aug clang_fmg
		au!
		au FileType h,cpp,c,hpp nnoremap <Leader>i :call ClangFmt()<cr>
	aug END

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

		nnoremap <buffer> gd <plug>(lsp-definition)
		nnoremap <buffer> <f2> <plug>(lsp-rename)
		nnoremap <Leader>s <plug>(lsp-workspace-symbol)
		nnoremap <Leader>m :LspDocumentSymbol<cr>:sleep 100ms<cr>:ccl<cr>:Quickfix<cr>
		nnoremap <Leader>d <plug>(lsp-definition)
		nnoremap <Leader>r <plug>(lsp-references)
	endfunction

	augroup lst_enable
		au!
		" call s:on_lsp_buffer_enabled only for languages that has the server registered.
		autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
	augroup END

" ------------------------------------------------------------------------------
" Window navigation 
	let s:last_switch_op = "buf"
	let s:last_buf = ""
	let s:last_win = ""
	aug buf_switch
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
				" execute ':b ' . s:last_buf
				execute ':echo ' . s:last_buf
			endif
		elseif s:last_switch_op =~ "win"
			if s:last_win != ""
				" execute ':echo ' . s:last_buf
				:exe s:last_win . "wincmd w"
			endif
		endif
	endfunc

	" nnoremap <silent> <tab> :call SwitchBufOrWin()<cr>
	nnoremap <tab> :call SwitchBufOrWin()<cr>

" ------------------------------------------------------------------------------
" Folds
	" Fold jumping with alt key.
	nnoremap <M-j> zj
	nnoremap <M-k> zk

	" Use fold level provided by count and remember it for repetition.
	let s:last_fold_level = 1
	func! FoldToLevel()
		set foldenable
		if v:count != 0
			let s:last_fold_level = v:count
		endif

		let &foldlevel = s:last_fold_level
	endfunc

	nnoremap <Leader>f :call FoldToLevel()<cr>

" ------------------------------------------------------------------------------
" Snippets
	nmap <Leader>-- o<esc>0D2a/<esc>77a-<esc>
	nmap <Leader>head <Leader>--2o<esc>75a-<esc>kA<Tab>

" ------------------------------------------------------------------------------
" Searching
	"Use ripgrep when installed.
	if executable('rg')
		let $FZF_DEFAULT_COMMAND = 
					\'rg --files --hidden --follow '.
					\'--glob "!.git" --glob "!.svn" --glob "!.hg"'

		command! -bang -nargs=* Rg
					\ call fzf#vim#grep(
					\   'rg --column --line-number --no-heading --color=always' . 
					\   ' --smart-case --follow --glob "!.git" --glob "!.svn" '
					\   '--glob "!.hg" '.shellescape(<q-args>), 1,<bang>0)


		nnoremap <Leader>R :Rg <c-r>=expand("<cword>")<cr>
	endif

	" Use silver searcher when installed.
	if executable('ag')
		command! -nargs=* -bang Ag call fzf#vim#ag_raw('-f --ignore-dir={.git,.svn} ' . <q-args> . ' .')
	endif

	" Try to make a fzf query for file with oposite extension.
	function! FindHeaderOrSource()
		let ext = expand("%:e")
		let fileName = expand("%:t:r")

		if ext =~ 'cpp' 
			let ext = 'h'
		elseif ext =~ 'h'
			let ext = 'cpp'
		else 
			let ext = ''
		endif

		exec ':FZF --query=' . fileName . '.' . ext
	endfunction

	nnoremap <Leader>p :Files .<cr> 
	nnoremap <Leader>b :Buffers .<cr> 
	nnoremap <Leader>t :BTags<cr>
	nnoremap <Leader>l :BLines<cr>
	nnoremap <Leader>o :call FindHeaderOrSource()<CR>

" ------------------------------------------------------------------------------
" Utils
	function ClearQuickfixList()
		call setqflist([])
	endfunction
	command! ClearQuickfixList call ClearQuickfixList()

" ------------------------------------------------------------------------------
" Build tools
	let s:build_tools = [':make']
	let s:build_tool_active = get(s:build_tools, 0, ':make')

	func! BuildToolsClear()
		let s:build_tools = []
	endfunc

	func! BuildToolsAdd(tool)
		call add(s:build_tools, a:tool)
	endfunc

	func! s:BuildToolsSelect(tool, bang)
		let s:build_tool_active = a:tool
		let s:build_tool_active = substitute(s:build_tool_active, '\\ ', ' ', 'g')
		let s:build_tool_active = substitute(s:build_tool_active, "\'", '', 'g')
		let s:build_tool_active = substitute(s:build_tool_active, "\\\"", '\"', 'g')

		if a:bang != 0
			call s:BuildToolsBuild()
		endif
	endfunc

	func! s:BuildToolsBuild()
		exec s:build_tool_active
	endfunc

	command! -nargs=1 -bang BuildToolsSelect call <SID>BuildToolsSelect(string(<q-args>), <bang>0)
	command! -bang Build call fzf#run(fzf#wrap({'source' : s:build_tools, 'sink' : 'BuildToolsSelect<bang>'}))
	command! BuildToolsBuild call <SID>BuildToolsBuild()

	nnoremap <F5> :BuildToolsBuild<cr>

" ------------------------------------------------------------------------------
" Menus
	" Use <TAB> to select the popup menu:
	inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

	" Terminal binding to escape from the insert mode.
	" Note: Breaks return from FZF menu.
	"	tnoremap <Esc> <C-\><C-n>

" ------------------------------------------------------------------------------
" Text nevigation
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

	" maybe use the switchbuf=useopen??
	nnoremap <Leader>v :e $MYVIMRC<cr>

	set encoding=utf-8

	" IMPORTANT: :help Ncm2PopupOpen for more information
	set completeopt=noinsert,menuone,noselect

	set cmdheight=2
	set updatetime=300
	set shortmess+=c
	set signcolumn=yes

	if g:os =~ "Windows"
		language en
	endif 

	set wildmenu
	set cursorline
	set autowriteall autoread
	set langmenu=en_US.UTF-8
	set foldmethod=indent nofen foldopen-=block,hor foldnestmax=1
	set splitbelow splitright
	set number relativenumber
	set matchpairs+=<:>
	set noshowmatch
	set shiftwidth=2 ts=2
	set scrolloff=5
	set list listchars=space:·,tab:→\ 
	set ignorecase smartcase
	set hls
	set backspace=indent,eol,start

	colorscheme gruvbox
	" The colors look a bit more dim with the term off.
	set termguicolors
	set bg=dark

	" Highlight as error everything above 100 column.
 	" match Error '/\%100v.\+/'
