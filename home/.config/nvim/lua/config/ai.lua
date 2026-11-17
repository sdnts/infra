vim.pack.add({ "https://github.com/supermaven-inc/supermaven-nvim" })
require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = "<D-Enter>",
		clear_suggestion = "<D-BS>",
		accept_word = "<D-l>",
	},
	ignore_filetypes = {
		markdown = true,
		["markdown.mdx"] = true,
	},
})
