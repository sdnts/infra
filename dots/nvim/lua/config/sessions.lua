vim.pack.add({ { src = "https://github.com/stevearc/resession.nvim", version = "stable" } })
require("resession").setup()

vim.keymap.set(
	"n",
	"<Leader>Sl",
	function() require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true }) end,
	{ desc = "Load directory session" }
)
vim.api.nvim_create_autocmd(
	"VimLeavePre",
	{ callback = function() require("resession").save(vim.fn.getcwd(), { dir = "dirsession", notify = false }) end }
)
