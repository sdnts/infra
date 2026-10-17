vim.pack.add({
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/s1n7ax/nvim-window-picker",
})
require("neo-tree").setup({
	close_if_last_window = true,
	enable_git_status = false,
	window = {
		position = "right",
		width = 50,
		mappings = {
			["<Left>"] = "close_node",
			["<Right>"] = "open_with_window_picker",
			["<Enter>"] = "open_with_window_picker",
			["c"] = "add",
			["y"] = "copy",
			["Y"] = {
				desc = "Copy relative path",
				function(state)
					local node = state.tree:get_node()
					if not node or node.type ~= "file" then return end

					local relative_path = vim.fs.relpath(state.path, node:get_id())
					if not relative_path then
						vim.notify("Could not make path relative to the Neo-tree root", vim.log.levels.ERROR)
						return
					end

					vim.fn.setreg("+", relative_path)
					vim.notify("Copied: " .. relative_path)
				end,
			},
			["m"] = "move",
		},
	},
	source_selector = {
		sources = {
			{ source = "filesystem", display_name = "Explore" },
		},
	},
	filesystem = {
		follow_current_file = {
			enabled = true,
		},
		filtered_items = {
			hide_dotfiles = false,
			hide_ignored = true,
			hide_by_name = { "node_modules" },
			visible = true,
			never_show = {
				".DS_Store",
				".git",
			},
		},
		use_libuv_file_watcher = true,
	},

	event_handlers = {
		{
			event = "file_moved",
			handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
		},
		{
			event = "file_renamed",
			handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
		},
	},
})
require("window-picker").setup({ hint = "floating-big-letter" })

vim.keymap.set("n", "<D-e>", function() vim.cmd("Neotree toggle reveal_force_cwd") end, { desc = "Open Neotree" })
