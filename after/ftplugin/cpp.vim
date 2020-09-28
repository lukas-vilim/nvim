" Formatting {{{
	" let g:clang_format_style = '"' . s:path . '\tools\clang\.clang-format"'
	let g:clang_format_style = 'file'

	func! ClangFmt()
		let current_line = line('.')
		let l:lines = string(current_line).':'.string(current_line + v:count)
		let clang_tools_path = s:path . '\tools\clang\'

		" let style_arg = '-style=\"' . clang_tools_path . '.clang-format\"'
		" echo style_arg
		" python import sys
		" exec 'python sys.argv = ["' . style_arg . '"]'
		exec 'pyf ' . clang_tools_path . 'clang-format.py'
	endfunc

	aug clang_fmg
		au!
		au FileType h,cpp,c,hpp nnoremap <Leader>i :call ClangFmt()<cr>
	aug END
	"}}}
