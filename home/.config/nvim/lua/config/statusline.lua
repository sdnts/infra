local function filename()
	if vim.bo.buftype == "terminal" then return "%t" end
	-- `%f` is the buffer path relative to Neovim's current working directory.
	return "%f%m%r"
end

local function lsp()
	if MiniStatusline.is_truncated(75) then return "" end

	local names = vim.tbl_map(function(client) return client.name end, vim.lsp.get_clients({ bufnr = 0 }))
	if #names == 0 then return "" end

	local ft = vim.bo.filetype
	if ft == "" then return "" end
	local ok, icons = pcall(require, "mini.icons")
	if ok then ft = icons.get("filetype", ft) end

	return ft .. " " .. table.concat(names, " ")
end

require("mini.statusline").setup({
	content = {
		active = function()
			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
			local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local file = filename()

			return MiniStatusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineFilename", strings = { file } },
				"%<", -- Mark general truncate point
				"%=", -- End left alignment
				{ strings = { diagnostics } },
				{ hl = "MiniStatuslineDevinfo", strings = { lsp() } },
			})
		end,

		inactive = function()
			local mode = MiniStatusline.section_mode({ trunc_width = 120 })
			local file = filename()

			return MiniStatusline.combine_groups({
				{ hl = "MiniStatuslineInactive", strings = { mode } },
				{ hl = "MiniStatuslineFilename", strings = { file } },
			})
		end,
	},
})
