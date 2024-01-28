vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "Q", "@q")

vim.keymap.set("n", "[q", ":cn<cr>")
vim.keymap.set("n", "]q", ":cp<cr>")
vim.keymap.set("n", "<cr>", ":nohl<cr><cr>")

if jit.os == 'Windows' then
	-- Unmap this as it hangs the terminal on windows.
	vim.keymap.set("n", "<C-z>", "<Nop>")
end
