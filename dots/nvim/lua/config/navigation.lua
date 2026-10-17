require("mini.jump2d").setup({ view = { dim = true }, mappings = { start_jumping = "f" } })

require("mini.pick").setup()
require("mini.extra").setup()

vim.keymap.set(
	"n",
	"<D-p>",
	function()
		Snacks.picker.files({
			hidden = true,
			exclude = { ".git", ".zig-cache", "zig-out", "zig-pkg", "node_modules" },
		})
	end,
	{ desc = "Open file" }
)
vim.keymap.set("n", "<D-S-f>", function() Snacks.picker.grep() end, { desc = "Find in project" })
