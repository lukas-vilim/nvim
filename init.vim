
" VIMRC {{{
	set exrc
	" set secure

	let mapleader="\ "
	nnoremap <Leader>v :e $MYVIMRC<cr>

	" source any written .vim file.
	aug config_save_hook
		" Clear the group.
		au!
		" Auto reload any .vim configuration and output its name.
		au BufWritePost *.vim so % | echo "Config reloaded: " . expand("%")
	aug END

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

	" configuration path
	let g:config_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
	let g:tools_path = g:config_path . "/tools/"

	" Setup path to external tools
	let $PATH .= ";" . g:config_path . "/tools/ctags/"
	let $PATH .= ";" . g:config_path . "/tools/fd/"

	set modeline modelines=5
	if g:os == 'Windows'
		" Not implemented on linux.
		set mle
	endif

	set undofile

	" }}}
" Utils {{{
	function! GetVisualSelection()
		let [line_start, column_start] = getpos("'<")[1:2]
		let [line_end, column_end] = getpos("'>")[1:2]
		let lines = getline(line_start, line_end)
		if len(lines) == 0
			return ''
		endif

		let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
		let lines[0] = lines[0][column_start - 1:]

		return join(lines, "\n")
	endfunction

	function! ClearQuickfixList()
		call setqflist([])
	endfunction
	command! ClearQuickfixList call ClearQuickfixList()
	" }}}
" Plugins {{{
	" Prevents the annoyance of inconsisten indent setting differing on file type.
	filetype plugin on
	filetype plugin indent off

	call plug#begin(g:config_path . '/plugged')
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
		Plug 'tpope/vim-obsession'

		" Highlights yanked selection.
		Plug 'machakann/vim-highlightedyank'

		" This could be a nice replacement for the :Explore
		Plug 'vifm/vifm.vim'

		" ncm2 and dependencies
		Plug 'roxma/nvim-yarp'
		Plug 'ncm2/ncm2'
		Plug 'ncm2/ncm2-bufword'
		Plug 'ncm2/ncm2-path'

		" vim lsp and dependencies.
		Plug 'prabirshrestha/async.vim'
		Plug 'prabirshrestha/vim-lsp'
		Plug 'ncm2/ncm2-vim-lsp'
		Plug 'ncm2/ncm2-racer'
	call plug#end()
	"}}}
" Completion + ncm2 {{{
	" IMPORTANT: :help Ncm2PopupOpen for more information
	set completeopt=noinsert,menuone,noselect

	" Use <TAB> to select the popup menu:
	inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

	" enable ncm2 for all buffers
	autocmd BufEnter * call ncm2#enable_for_buffer()

	" let g:lsp_log_verbose = 1
	" let g:lsp_log_file = 'vim-lsp.log'	" vim-lsp

	" enable for include debug when something gets odd...
	let g:lsp_diagnostics_enabled = 0
	let g:lsp_highlight_references_enabled = 1
	let g:lsp_enable_clangd = 0

	if executable('pyls')
		" pip install python-language-server
		au User lsp_setup call lsp#register_server({
					\ 'name': 'pyls',
					\ 'cmd': {server_info->['pyls']},
					\ 'whitelist': ['python'],
					\ })
	endif

	if g:lsp_enable_clangd == 1 && executable('clangd')
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
		nnoremap <buffer> <Leader>s <plug>(lsp-workspace-symbol)
		" nnoremap <buffer> <Leader>m :LspDocumentSymbol<cr>:sleep 100ms<cr>:ccl<cr>:Quickfix<cr>
		nnoremap <buffer> <Leader>d <plug>(lsp-definition)
		nnoremap <buffer> <Leader>r <plug>(lsp-references)
	endfunction

	augroup lst_enable
		au!
		" call s:on_lsp_buffer_enabled only for languages that has the server registered.
		autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
	augroup END

	"}}}
" UI and Windows {{{
	colorscheme gruvbox

	" The colors look a bit more dim with the term off.
	set termguicolors
	set bg=dark
	
	if g:os =~ "Windows"
		language en
	endif 

	set encoding=utf-8
	set langmenu=en_US.UTF-8

	" Highlight as error everything above 100 column.
 	" match Error '/\%100v.\+/'

	set splitbelow splitright
	set cursorline number relativenumber

	set wildmenu
	set cmdheight=2
	set updatetime=300
	set shortmess+=c
	set signcolumn=yes

	set matchpairs+=<:>
	set shiftwidth=2 ts=2 noexpandtab nosmarttab softtabstop=2
	set scrolloff=5
	set list listchars=space:·,tab:→\ 

	nnoremap <C-h> <C-w>h
	nnoremap <C-l> <C-w>l
	nnoremap <C-j> <C-w>j
	nnoremap <C-k> <C-w>k

	" Switch to previous buffer.
	" nnoremap <tab> :b#<cr>

	let s:hg_list= []

	highlight Hg0 ctermbg=Black guibg=Black
	highlight Hg1 ctermbg=DarkRed guibg=DarkRed
	highlight Hg2 ctermbg=DarkGreen guibg=DarkGreen
	highlight Hg3 ctermbg=DarkBlue guibg=DarkBlue
	highlight Hg4 ctermbg=DarkMagenta guibg=DarkMagenta
	highlight Hg5 ctermbg=DarkYellow guibg=DarkYellow
	highlight Hg6 ctermbg=Gray guibg=Gray
	highlight Hg7 ctermbg=Yellow guibg=Yellow
	highlight Hg8 ctermbg=Brown guibg=Brown
	highlight Hg9 ctermbg=Magenta guibg=Magenta

	let g:hg_inc_default = 1

	" mode: 
	" 0 => motion
	" 1 => normal <cword> 
	" 2 => visual mode 
	func! s:hg_push_selection(mode, incremental)
		" Visual mode check.
		if a:mode == 0
			" yank to z regster.
			norm! `[v`]"zy
			let pattern = getreg('z')
		elseif a:mode == 1
			let pattern = expand('<cword>')
		elseif a:mode == 2
			let pattern = GetVisualSelection()
		else
			echoerr 'No mode set!'
			return
		endif

		call s:hg_push(pattern, a:incremental)
	endfunc

	func! s:hg_push(pattern, incremental)
		if a:incremental == 1
			let group = string(len(s:hg_list))
		else
			let group = input('Highlight group number (0..9):')
		endif

		if group > 9
			echoerr "Ran out of highlight groups!"
			return
		endif

		let id = matchadd('Hg'.group, a:pattern)
		call add(s:hg_list, id)
	endfunc

	func! s:hg_push_inc(mode)
		call s:hg_push_selection(a:mode, 1)
	endfunc

	func! s:hg_clear(force)
		if a:force == 1
			let matches = getmatches()
			for match in matches
				call matchdelete(match['id'])
			endfor
		else
			for id in s:hg_list
				call matchdelete(id)
			endfor
		endif

		let s:hg_list = []
	endfunc

	func! s:hg_pop()
		if empty(s:hg_list)
			return
		endif

		let last = s:hg_list[-1]
		call matchdelete(last)
	endfunc

	command! HgPop call s:hg_pop()
	command! -bang HgClear call s:hg_clear(<bang>0)
	command! -nargs=1 -bang HgAdd call s:hg_push('<args>', <bang>0)

	nnoremap <Plug>(n-hg-inc-add) :set opfunc=<sid>hg_push_inc<cr>g@
	nnoremap <Plug>(n-hg-add) :call s:hg_push(1, g:hg_inc_default)<cr>
	vnoremap <Plug>(i-hg-add) :<c-u>call s:hg_push(2, g:hg_inc_default)<cr>

	nmap <Leader>h <Plug>(n-hg-inc-add)
	vmap <Leader>h <Plug>(i-hg-add)

	" Stop window from resizing.
	set noequalalways

	" Run terminal and setup mappings.
	func! s:run_terminal()
		terminal

		" Terminal binding to escape from the insert mode.
		" Note: Breaks return from FZF menu if setup globally.
		tnoremap <buffer> <Esc> <C-\><C-n>
		tnoremap <buffer> <C-w>l <C-\><C-n><C-w>l
		tnoremap <buffer> <C-w>h <C-\><C-n><C-w>h
		tnoremap <buffer> <C-w>j <C-\><C-n><C-w>j
		tnoremap <buffer> <C-w>k <C-\><C-n><C-w>k
		tnoremap <buffer> <C-u> <C-\><C-n><C-u>
		tnoremap <buffer> <C-d> <C-\><C-n><C-d>

		tnoremap <buffer> <C-h> <C-\><C-n><C-w>h
		tnoremap <buffer> <C-l> <C-\><C-n><C-w>l
		tnoremap <buffer> <C-j> <C-\><C-n><C-w>j
		tnoremap <buffer> <C-k> <C-\><C-n><C-w>k
	endfunc

	command! Term call s:run_terminal()

	func! s:run_vifm()
		tabnew
		set guitablabel='VIFM'

		Vifm
		tnoremap <buffer> <Esc> <C-\><C-n>
	endfunc

	command! FB call s:run_vifm()

	"}}}
" Folds {{{
	set foldopen-=block,hor foldnestmax=5

	" custom fold text function.
	func! FoldText()
		return '+-- ' . string(v:foldend - v:foldstart) . ' lines '
	endfunc
	set foldtext=FoldText()

	func! FoldTextWithFirstLine()
		return substitute(getline(v:foldstart), '{', '', 'g') . ' [' . string(v:foldend - v:foldstart) . ']'
	endfunc

	" Fold jumping with alt key.
	nnoremap <M-j> zj
	nnoremap <M-k> zk

	" Use fold level provided by count.
	let g:prefered_fold_method = 'indent'
	func! SetFolding()
		set foldmethod=indent foldenable
		let &foldmethod = g:prefered_fold_method
		let &foldlevel = v:count
	endfunc

	nnoremap <Leader>f :call SetFolding()<cr>
	"}}}
" Snippets {{{
	nmap <Leader>-- o<esc>0D2a/<esc>77a-<esc>
	nmap <Leader>todo o// TODO(vilimluk): <!!><esc>
	" nmap <Leader>head <Leader>--2o<esc>75a-<esc>kA<Tab>
	" }}}
" Searching {{{
	set ignorecase smartcase noshowmatch hls

	" Turn off autohighlight by hitting enter.
	nnoremap <CR> :nohl<CR><CR>

	let g:fzf_follow = 1
	let g:fzf_hidden = 1
	let g:fzf_preview_window = []
	let g:fzf_layout = { 'down': '40%' }

	let cmd = 'rg --files'

	if g:fzf_follow
		let cmd .= ' --follow'
	endif

	if g:fzf_hidden 
		let cmd .= ' --hidden'
	endif
	
	let cmd .= ' --glob "!.git" --glob "!.svn" --glob "!.hg"'
	let $FZF_DEFAULT_COMMAND = cmd

	"Use ripgrep when installed.
	if executable('rg')
		let g:rg_globs = ['!.hg', '!.svn', '*.h', '*.cpp', '*.c']
		function! CallRg(args, bang)
			let globs = ''
			if !empty(g:rg_globs)
				let tmp = g:rg_globs[:]
				call map(tmp, {idx, val -> '--glob "' . val . '"'})
				let globs = join(tmp, ' ') 
			endif

			call fzf#vim#grep(
			\   'rg ' . globs . ' --column --line-number --no-heading --color=always' . 
			\   ' --smart-case --follow '.shellescape(a:args), 1, a:bang)
		endfunction

		command! -bang -nargs=* Rg call CallRg(<q-args>, <bang>0)

		nnoremap <Leader>L :Rg <c-r>=expand("<cword>")<cr>
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

	let s:taglist = []
	func! s:TagSelected(line)
		echom s:taglist[str2nr(a:line)]['cmd']
	endfunc

	func! s:TagSelect(tag)
		let s:taglist = taglist(a:tag)
		let entries = s:taglist[:]

		call map(entries, {key, val -> key .  "	" . val['kind'] . "	 " . val['filename']})
		call fzf#run(fzf#wrap({'source' : entries, 'sink' : function('<SID>TagSelected'), 'options' : '--header=' . a:tag}))
	endfunc

	let s:tag_cache = []
	func! s:TagSearch(arg)
		call fzf#run(fzf#wrap({'source' : 'cat tags_keys', 'sink' : 'tselect', 'options' : '--query=' . shellescape(a:arg)}))
	endfunc

	command! -nargs=1 TagSelect call <SID>TagSelect(<q-args>)
	" Use the tags_keys file as an input for tselect.
	" command! TagSearch call fzf#run(fzf#wrap({'source' : readfile('tags_keys'), 'sink' : function('<SID>TagSelect')}))
	command! TagSearch call s:TagSearch(expand('<cword>'))

	" Override the Window command completion.
	command! W :w

	nnoremap <Leader>p :Files .<cr> 
	nnoremap <Leader>P :FZF --query=<c-r>=expand("<cword>")<cr><cr>
	nnoremap <Leader>b :Buffers .<cr> 
	nnoremap <Leader>t :BTags<cr>
	nnoremap <Leader>T :TagSearch<cr>
	nnoremap <Leader>l :BLines<cr>
	nnoremap <Leader>o :call FindHeaderOrSource()<CR>


	"}}}
" Build tools {{{
	let s:build_tools = {}
	let s:build_tool_active = ''

	func! BuildToolsClear()
		let s:build_tools = {}
	endfunc

	" name, makeprg, errformat
	func! s:BuildToolsAdd(name, tool)
		if !has_key(a:tool, 'makeprg') || !has_key(a:tool, 'errorformat')
			echoerr 'Tool: Bad format!'
			return
		endif

		let s:build_tools[a:name] = a:tool
	endfunc

	func! s:BuildToolsSelect(tool, bang)
		let option = substitute(a:tool, '\\ ', ' ', 'g')
		let option = substitute(option, "'", '', 'g')

		let s:build_tool_active = option

		if a:bang != 0
			call s:BuildToolsBuild()
		endif
	endfunc

	func! s:BuildToolsBuild()
		let tools = s:build_tools[s:build_tool_active]
		let &makeprg = tools['makeprg']
		let &efm = tools['errorformat']

		:Make
	endfunc

	command! -nargs=* BuildToolsAdd call <SID>BuildToolsAdd(<args>)
	command! -nargs=1 -bang BuildToolsSelect call <SID>BuildToolsSelect(string(<q-args>), <bang>0)
	command! -bang BuildSelect call fzf#run(fzf#wrap({'source' : sort(keys(s:build_tools)), 'sink' : 'BuildToolsSelect<bang>', 'options' : '--header="Selected: ' . s:build_tool_active . '"'}))
	command! Build call <SID>BuildToolsBuild()

	nnoremap <Leader>m :Build<cr>
	nnoremap <Leader>M :BuildSelect!<cr>

	nnoremap ]q :cn<cr>
	nnoremap [q :cp<cr>

	"}}}
" Text navigation {{{
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

	" inoremap <C-l> <Right>
	" inoremap <C-j> <Down>
	" inoremap <C-k> <Up>
	" }}}
" Text manipulation {{{
	set backspace=indent,eol,start

	" the clipboard now action is now bound to unnamed " and + registers.
	" Immediate pasting!
	set clipboard^=unnamed,unnamedplus

	" Consistent yank.
	nnoremap Y y$

	" One hit macro play.
	nnoremap Q @q

	" One hit apply Q on all lines.
	vnoremap Q :normal Q<cr>

	"}}}
" Tags {{{
	let g:gutentags_project_root = 'c:/!bi/'
	let g:gutentags_resolve_symlinks = 1

	func! MakeTagKeys()
		let lines = readfile('tags')
		call map(lines, {key, val -> strpart(val, 0, stridx(val, '	'))})
		call uniq(lines)
		call writefile(lines, 'tags_keys')
	endfunc

	" Common ctags command.
	let s:ctags_cmd = 
				\"!ctags.exe -R --c++-kinds=+p --fields=+iaS --extras=+q ".
				\"--exclude=.git --exclude=.svn --exclude=extern --verbose=no"

	func! RebuildTags()
		echo s:ctags_cmd
		exec s:ctags_cmd . " ./Enfusion" | exec s:ctags_cmd . " -a ./A4Gamecode"
		call MakeTagKeys()
		echom 'Tags rebuilt!'
	endfunc

	" Rebuild tags for the whole project.
	nmap <Leader>rt :call RebuildTags()<cr>

	" Auto update ctags on file save.
	" aug ctags_save_hook
	" 	" Clear group.
	" 	au!
		
	" 	" Update ctags for modified file.
	" 	au BufWritePost *.h,*.cpp,*hpp,*.c
	" 				\silent exec ctags_cmd . " -a " . expand("%") | 
	" 				\echo "Tags updated: " . expand("%")
	" aug END
	" }}}
" Buffers {{{
	set autowriteall autoread
	set nofixendofline
	set noswapfile

	aug file_hooks
		au!

		" au FocusGained,BufEnter * :silent! checktime
		" au FocusLost,WinLeave * :silent! w
		au FileType c,cpp,cs,java set commentstring=//\ %s
		au CursorHold * checktime
	aug END
	"}}}
" Project {{{
	func! s:source_project()
		let path = getcwd() . "/exrc.vim"
		if filereadable(path)
			echo "Project loaded"
			execute 'so ' . path
		endif
	endfunc

	command! SourceProject call s:source_project()
	SourceProject
	"}}}
" Git {{{
	nnoremap <Leader>gs :Gstatus<cr>
	nnoremap <Leader>gc :Gcommit<cr>
	" }}}
" Presentation {{{
	nnoremap <c-j> :bn<cr>
	nnoremap <c-k> :bp<cr>
	nnoremap <c-p> o• 

	set nolist
	set nohls
	set nonumber norelativenumber

	" }}}

" vim:set foldmethod=marker foldtext=FoldTextWithFirstLine():
