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
	" let s:completion = "ale"
	" let s:completion = "ncm"
	let s:completion = "coc"

	call plug#begin(s:path . '/plugged')

		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
		Plug 'morhetz/gruvbox'
		Plug 'junegunn/fzf'
		Plug 'junegunn/fzf.vim'
		Plug 'tpope/vim-surround'
		Plug 'tpope/vim-fugitive'
		Plug 'tpope/vim-commentary'
		Plug 'machakann/vim-highlightedyank'

		" ncm2 and dependencies
		if s:completion == "ncm"
			Plug 'roxma/nvim-yarp'
			Plug 'ncm2/ncm2'
			Plug 'ncm2/ncm2-bufword'
			Plug 'ncm2/ncm2-path'
			" ncm2 clang service
			Plug 'ncm2/ncm2-pyclang'
		endif

		if s:completion == "ale"
			Plug 'dense-analysis/ale'
		endif 

		if s:completion == "coc"
			Plug 'neoclide/coc.nvim', {'branch': 'release'}
		endif

	call plug#end()

" ------------------------------------------------------------------------------
"  Coc

	if s:completion == "coc"
		" if hidden is not set, TextEdit might fail.
		" set hidden

		" Some servers have issues with backup files, see #649
		" set nobackup
		" set nowritebackup

		" Use tab for trigger completion with characters ahead and navigate.
		" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
		inoremap <silent><expr> <TAB>
					\ pumvisible() ? "\<C-n>" :
					\ <SID>check_back_space() ? "\<TAB>" :
					\ coc#refresh()
		inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

		function! s:check_back_space() abort
			let col = col('.') - 1
			return !col || getline('.')[col - 1]  =~# '\s'
		endfunction

		" Use <c-space> to trigger completion.
		inoremap <silent><expr> <c-space> coc#refresh()

		" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
		" Coc only does snippet and additional edit on confirm.
		inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
		" Or use `complete_info` if your vim support it, like:
		" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

		" Use `[g` and `]g` to navigate diagnostics
		nmap <silent> [g <Plug>(coc-diagnostic-prev)
		nmap <silent> ]g <Plug>(coc-diagnostic-next)

		" Remap keys for gotos
		nmap <silent> gd <Plug>(coc-definition)
		nmap <silent> gy <Plug>(coc-type-definition)
		nmap <silent> gi <Plug>(coc-implementation)
		nmap <silent> gr <Plug>(coc-references)

		" Use K to show documentation in preview window
		nnoremap <silent> K :call <SID>show_documentation()<CR>

		function! s:show_documentation()
			if (index(['vim','help'], &filetype) >= 0)
				execute 'h '.expand('<cword>')
			else
				call CocAction('doHover')
			endif
		endfunction

		" Highlight symbol under cursor on CursorHold
		autocmd CursorHold * silent call CocActionAsync('highlight')

		" Remap for rename current word
		nmap <leader>rn <Plug>(coc-rename)

		" Remap for format selected region
		xmap <leader>f  <Plug>(coc-format-selected)
		nmap <leader>f  <Plug>(coc-format-selected)

		augroup mygroup
			autocmd!
			" Setup formatexpr specified filetype(s).
			autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
			" Update signature help on jump placeholder
			autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
		augroup end

		" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
		xmap <leader>a  <Plug>(coc-codeaction-selected)
		nmap <leader>a  <Plug>(coc-codeaction-selected)

		" Remap for do codeAction of current line
		nmap <leader>ac  <Plug>(coc-codeaction)
		" Fix autofix problem of current line
		nmap <leader>qf  <Plug>(coc-fix-current)

		" Create mappings for function text object, requires document symbols feature of languageserver.
		xmap if <Plug>(coc-funcobj-i)
		xmap af <Plug>(coc-funcobj-a)
		omap if <Plug>(coc-funcobj-i)
		omap af <Plug>(coc-funcobj-a)

		" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
		nmap <silent> <TAB> <Plug>(coc-range-select)
		xmap <silent> <TAB> <Plug>(coc-range-select)

		" Use `:Format` to format current buffer
		command! -nargs=0 Format :call CocAction('format')

		" Use `:Fold` to fold current buffer
		command! -nargs=? Fold :call     CocAction('fold', <f-args>)

		" use `:OR` for organize import of current buffer
		command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

		" Add status line support, for integration with other plugin, checkout `:h coc-status`
		set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

		" Using CocList
		" Show all diagnostics
		nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
		" Manage extensions
		nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
		" Show commands
		nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
		" Find symbol of current document
		nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
		" Search workspace symbols
		nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
		" Do default action for next item.
		nnoremap <silent> <space>j  :<C-u>CocNext<CR>
		" Do default action for previous item.
		nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
		" Resume latest coc list
		nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
	endif

" ------------------------------------------------------------------------------
" ncm2 

	if s:completion == "ncm"
		" enable ncm2 for all buffers
		autocmd BufEnter * call ncm2#enable_for_buffer()

		" IMPORTANT: :help Ncm2PopupOpen for more information
		set completeopt=noinsert,menuone,noselect

		" Use <TAB> to select the popup menu:
		inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
		inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

		" Prevent the new line after completion menu Enter:
		inoremap <expr> <CR> (pumvisible() ? "\<c-y>\ " : "\<CR>")

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
		autocmd FileType c,cpp nnoremap <buffer> <f12> :<c-u>call ncm2_pyclang#goto_declaration()<cr>
	endif

" ------------------------------------------------------------------------------
"  Ale

	if s:completion == "ale"
		let g:ale_linters = {'cpp': ['clangd']}
	endif

" ------------------------------------------------------------------------------
" Bindings 

	let mapleader="\ "

	" Snippets
	nmap <Leader>-- o<esc>0D2a/<esc>77a-<esc>
	nmap <Leader>head <Leader>--2o<esc>75a-<esc>kA<Tab>

	" FZF fuzzy finder binding.
	nmap <C-p> :Files .<CR> 
	nmap <Leader>t :BTags<CR>

	" python clang format.
	" map·<C-I>·:pyf ../clang-format.py<cr>
	" imap·<C-I>·<c-o>:pyf·<path-to-this-file>/clang-format.py<cr>

	command! -nargs=* -bang Ag call fzf#vim#ag_raw('-f --ignore-dir={.git,.svn} ' . <q-args> . ' .')

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

	aug buff_save_hook
		au!

		" if not readonly save the buffer.
		au FocusLost,BufLeave * if (&ro == 0) | w | endif
	aug END

" ------------------------------------------------------------------------------
" Basic settings.

	set cmdheight=2
	set updatetime=300
	set shortmess+=c
	set signcolumn=yes

	language en
	set langmenu=en_US.UTF-8
	set foldmethod=syntax nofen
	set splitbelow splitright
	set number relativenumber
	set shiftwidth=2 ts=2
	set list listchars=space:·,tab:→\ 
	set smartcase
	colorscheme gruvbox

	" Highlight as error everything above 100 column.
 	match Error '/\%100v.\+/'
