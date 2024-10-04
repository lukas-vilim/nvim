vim.api.nvim_create_user_command('Term',
	function()
		vim.api.nvim_command('term')
		vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', '<C-\\><C-n>', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-w>l', '<C-\\><C-n><C-w>l', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-w>h', '<C-\\><C-n><C-w>h', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-w>j', '<C-\\><C-n><C-w>j', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-w>k', '<C-\\><C-n><C-w>k', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-u>', '<C-\\><C-n><C-u>', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 't', '<C-d>', '<C-\\><C-n><C-d>', {noremap = true})
	end,
	{
		nargs = 0,
	})
