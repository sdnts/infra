require("mini.basics").setup()

require("mini.comment").setup()

require("mini.cursorword").setup()

require("mini.move").setup({
	mappings = {
		left = "",
		right = "",
		down = "<C-S-Down>",
		up = "<C-S-Up>",

		line_left = "",
		line_right = "",
		line_down = "<C-S-Down>",
		line_up = "<C-S-Up>",
	},
})

require("mini.pairs").setup()

require("mini.splitjoin").setup({ mappings = { toggle = "jj" } })

require("mini.surround").setup({ mappings = { add = "S", delete = "ds", replace = "cs" } })
