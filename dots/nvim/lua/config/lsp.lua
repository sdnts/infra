-------------
-- Plugins --
-------------

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
require("nvim-treesitter").install("all")

vim.pack.add({ "https://github.com/b0o/schemastore.nvim" })

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.enable({
	"astro",
	"fish_lsp",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"mdx_analyzer",
	"nixd",
	"nushell",
	"pyright",
	"tailwindcss",
	"taplo",
	"tsc",
	"yamlls",
	"zls",
})

vim.pack.add({ "https://github.com/saghen/blink.lib", "https://github.com/saghen/blink.cmp" })
local cmp = require("blink.cmp")
vim.env.CARGO_PROFILE_RELEASE_STRIP = "none"
cmp.build():pwait()
cmp.setup({
	completion = { list = { selection = { preselect = false } } },
	keymap = {
		preset = "default",
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
	},
})

------------
-- Keymap --
------------

vim.keymap.set("n", "<Leader>wz", function() require("mini.misc").zoom() end, { desc = "Focus pane" })

vim.keymap.set("n", "<Leader>pd", function() Snacks.picker.diagnostics() end, { desc = "Project diagnostics" })

vim.keymap.set("n", "<Leader>bd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<Leader>br", function() vim.lsp.buf.rename() end, { desc = "Rename Symbol" })
vim.keymap.set("n", "<Leader>b@", function() Snacks.picker.lsp_symbols() end, { desc = "Go to Symbol" })
vim.keymap.set("n", "<Leader>bca", function() vim.lsp.buf.code_action() end, { desc = "Show code actions" })
vim.keymap.set("n", "<D-.>", function() vim.lsp.buf.code_action() end, { desc = "Show code actions" })

vim.keymap.set("n", "<Leader>dd", function() vim.diagnostic.open_float() end, { desc = "Hover Diagnostic" })

vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "Go to references" })
vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Go to definition" })
vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Go to implementation" })

vim.keymap.set("n", "<D-k>", function() vim.lsp.buf.signature_help() end, { desc = "Show signature help" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Hover" })

--------------
-- Commands --
--------------

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		local language = vim.treesitter.language.get_lang(event.match)
		if language and vim.treesitter.language.add(language) then vim.treesitter.start(event.buf, language) end
	end,
})

vim.api.nvim_create_user_command(
	"OrganizeImports",
	function()
		vim.lsp.buf.code_action({
			apply = true,
			context = {
				only = { "source.organizeImports" },
				diagnostics = {},
			},
		})
	end,
	{}
)

vim.filetype.add({ extension = { mdx = "markdown.mdx" } })
vim.filetype.add({ extension = { zon = "zig" } })
vim.filetype.add({ extension = { bu = "yaml" } })
