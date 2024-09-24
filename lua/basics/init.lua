vim.g.mapleader = " "

require("basics.lazy")
require("basics.remap")
require("basics.set")
require("basics.term")

vim.cmd.colorscheme("gruvbox")

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function() vim.highlight.on_yank({timeout=400}) end,
})

vim.api.nvim_create_user_command("Config", function()
	local file = vim.fn.expand("$MYVIMRC")
	local dir = vim.fs.dirname(file)
	vim.api.nvim_command("cd " .. dir)
	vim.api.nvim_command("edit " .. file)
end, {})

vim.api.nvim_create_user_command("Cd", function(args)
	local path = vim.fn.expand("%")
	print(path)
	if args["nargs"] == 1 then
		path = args["args"]
	end

	local is_dir = vim.fn.isdirectory(path)
	if is_dir == 0 then
		local dir = vim.fs.dirname(path)
		vim.api.nvim_command("cd " .. dir)
	else
		vim.api.nvim_command("cd " .. path)
	end
end, {
	nargs	= '?',
	complete = "dir",
})
