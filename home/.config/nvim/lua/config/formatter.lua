vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
	formatters_by_ft = {
		astro = { "prettier" },
		c = { "clang_format" },
		go = { "gofmt" },
		lua = { "stylua" },
		markdown = { "oxfmt" },
		nix = { "nixfmt" },
		nu = { "nufmt" },
		ruby = { "rubocop" },
		terraform = { "terraform_fmt" },
		toml = { "taplo" },
		vue = { "oxfmt" },
		zig = { "zigfmt" },

		["_"] = function(bufnr)
			local conform = require("conform")
			if conform.get_formatter_info("oxfmt", bufnr).available then
				return { "oxfmt" }
			elseif conform.get_formatter_info("prettier", bufnr).available then
				return { "prettier" }
			else
				return {}
			end
		end,
	},
	format_on_save = {
		timeout_ms = 2000,
		lsp_format = "fallback",
	},
	formatters = {
		stylua = {
			append_args = { "--collapse-simple-statement", "Always" },
		},
		oxfmt = function() require("conform.util").from_node_modules("oxfmt") end,
		prettier = function() require("conform.util").from_node_modules("prettier") end,
	},
})

vim.api.nvim_create_user_command(
	"Format",
	function() require("conform").format({ async = false, lsp_fallback = true }) end,
	{}
)
