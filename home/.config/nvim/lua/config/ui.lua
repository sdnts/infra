vim.pack.add({ "https://github.com/tadaa/vimade" })
require("vimade").setup({
	recipe = { "default", { animate = false } },
	ncmode = "windows",
	fadelevel = 0.75,
})
