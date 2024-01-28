return {
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('telescope').setup {
				defaults = {
					file_ignore_patterns = {
						".uasset",
						".png",
						".mp4",
						".umap",
						".fbx",
						".archive",
						".locres",
						".po",
						".mo",
						".dll",
						".so",
						".lib",
						".exe",
						".ico",
						".TGA",
						".manifest",
						".locmeta",
					}
				}
			}

			local builtin = require('telescope.builtin')

			local git_or_direct = function ()
				if vim.fn['FugitiveIsGitDir']() == 1 then
					builtin.git_files({})
				else
					builtin.find_files({})
				end
			end

			vim.keymap.set('n', '<leader>p', git_or_direct)
			vim.keymap.set('n', '<leader>P', builtin.find_files, {})
			vim.keymap.set('n', '<leader>L', builtin.live_grep, {})
			vim.keymap.set('n', '<leader>l', builtin.current_buffer_fuzzy_find, {})
			vim.keymap.set('n', '<leader>b', builtin.buffers, {})
			vim.keymap.set('n', '<leader>T', builtin.tags, {})
			vim.keymap.set('n', '<leader>R', builtin.lsp_references, {})
			vim.keymap.set('n', '<leader>m', builtin.lsp_document_symbols, {})
			vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
			vim.keymap.set('n', '<leader>D', builtin.diagnostics, {})
		end
	}
}
