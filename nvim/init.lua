-- init.lua
-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Sensible defaults
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
	ui = { border = "rounded" },
	change_detection = { notify = false },
})

-- Colorscheme
vim.cmd.colorscheme("onedark")

vim.lsp.inlay_hint.enable(true)

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	severity_sort = true,
	float = { border = "rounded" },
})

-- Exit insert mode with "jj"
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Save with Ctrl+S in multiple modes
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file" })
