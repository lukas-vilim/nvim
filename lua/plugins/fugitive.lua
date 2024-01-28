return {
	{
		"tpope/vim-fugitive",

		config = function()
			vim.keymap.set("n", "<leader>gs", ":Git<cr>")
			vim.keymap.set("n", "<leader>gb", ":Git blame<cr>")
		end
	}
}
