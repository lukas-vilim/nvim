" Formatting {{{
	" let g:clang_format_style = '"' . s:path . '\tools\clang\.clang-format"'
	let g:clang_format_style = 'file'

	func! ClangFmt(mode)
		if a:mode == 0
			" motion
			let beg = line("'[")
			let end = line("']")
			let l:lines = string(beg).':'.string(end)
		elseif a:mode == 1
			" normal
			let current_line = line('.')
			let l:lines = string(current_line).':'.string(current_line + v:count)
		elseif a:mode == 2
			" visual
			let beg = line("'<")
			let end = line("'>")
			let l:lines = string(beg).':'.string(end)
		elseif a:mode == 3
			" custom
			let l:lines = 'all'
		else
			echoerr 'No mode set!'
			return
		endif

		let clang_tools_path = g:tools_path . 'clang\'
		exec 'pyf ' . clang_tools_path . 'clang-format.py'
	endfunc

	nnoremap <Leader>I :call ClangFmt(3)<cr>
	nnoremap <Leader>i :set opfunc=ClangFmt<cr>g@
	"}}}
