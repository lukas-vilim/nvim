vim.g.mapleader = " "

require("basics.lazy")
require("basics.remap")
require("basics.set")

vim.cmd.colorscheme("gruvbox")

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function() vim.highlight.on_yank({timeout=400}) end,
})
