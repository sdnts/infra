vim.api.nvim_create_user_command("Update", function()
	vim.pack.update(nil, { force = true })
	vim.cmd.TSUpdate()
end, {})

----------------
-- Appearance --
----------------

vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.spell = false
vim.opt.signcolumn = "no"
vim.opt.wrap = false
vim.opt.colorcolumn = "120"
vim.opt.termguicolors = true
vim.opt.mousemodel = "extend" -- Extend visual selection on right-clicks instead of opening a menu
vim.opt.showtabline = 1 -- only show the tabline when there is more than one tabpage
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.winborder = "rounded"
vim.opt.cmdheight = 0

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.pack.add({ "https://github.com/sainnhe/everforest" })
vim.g.everforest_background = "hard"
vim.cmd.colorscheme("everforest")

vim.pack.add({ "https://github.com/tadaa/vimade" })
require("vimade").setup({
	recipe = { "default", { animate = false } },
	ncmode = "windows",
	fadelevel = 0.75,
})

------------
-- Keymap --
------------
---

vim.g.mapleader = " "

-- :keymap:tabs
vim.keymap.set("n", "<D-t>", ":tabnew<CR>", { desc = "Create tab" })
vim.keymap.set("n", "<Leader>tn", ":tabnext<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<Leader>tp", ":tabprevious<CR>", { desc = "Go to previous tab" })

vim.keymap.set("n", "<Leader>t1", ":tabn 1<CR>", { desc = "Go to tab 1" })
vim.keymap.set("n", "<Leader>t2", ":tabn 2<CR>", { desc = "Go to tab 2" })
vim.keymap.set("n", "<Leader>t3", ":tabn 3<CR>", { desc = "Go to tab 3" })
vim.keymap.set("n", "<Leader>t4", ":tabn 4<CR>", { desc = "Go to tab 4" })
vim.keymap.set("n", "<Leader>t5", ":tabn 5<CR>", { desc = "Go to tab 5" })
vim.keymap.set("n", "<Leader>t6", ":tabn 6<CR>", { desc = "Go to tab 6" })
vim.keymap.set("n", "<Leader>t7", ":tabn 7<CR>", { desc = "Go to tab 7" })
vim.keymap.set("n", "<Leader>t8", ":tabn 8<CR>", { desc = "Go to tab 8" })
vim.keymap.set("n", "<Leader>t9", ":tabn 9<CR>", { desc = "Go to tab 9" })

-- :keymap:buffers
vim.keymap.set("n", "<Leader>bs", ":w<CR>", { desc = "Save current buffer" })
vim.keymap.set("n", "<D-s>", ":w<CR>", { desc = "Save current buffer" })

vim.keymap.set("n", "<Leader>bS", ":wa<CR>", { desc = "Save all buffers" })
vim.keymap.set("n", "<D-Shift-s>", ":wa<CR>", { desc = "Save all buffers" })

-- :keymap:splits
vim.keymap.set("n", "<D-\\>", ":vsp<CR><cmd>normal! zz<CR>", { desc = "Split pane to the right" })
vim.keymap.set("n", "<D-->", ":sp<CR><cmd>normal! zz<CR>", { desc = "Split pane below" })
for arrow, motion in pairs({ Up = "k", Down = "j", Left = "h", Right = "l" }) do
	vim.keymap.set("n", "<C-w><" .. arrow .. ">", function()
		local previous = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(motion)

		if vim.api.nvim_get_current_win() == previous and vim.env.REX_SESSION then
			vim.system({
				"rex",
				"focus",
				arrow:lower(),
				"-s",
				vim.env.REX_SESSION,
			})
		end
	end, { desc = "Focus Neovim or Rex panes" })
end
vim.keymap.set("n", "<D-w>", ":close<CR>", { desc = "Close current pane" })
vim.keymap.set("n", "<Leader>w=", "<C-w>=", { desc = "Balance panes (make them equally high and wide)" })
vim.keymap.set("n", "<Leader>wz", function() require("mini.misc").zoom() end, { desc = "Focus pane" })

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "p", [["_dP]])
vim.keymap.set("n", "zz", "za", { desc = "Toggle fold on cursor" })

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
require("mini.keymap").setup()
require("mini.cmdline").setup()
require("mini.clue").setup({ triggers = { { mode = { "n", "x" }, keys = "<Leader>" } } })

vim.pack.add({ "https://github.com/folke/snacks.nvim" })
require("snacks").setup({
	indent = {
		enabled = true,
		animate = { enabled = false },
		scope = { only_current = true },
	},
})

require("config.ai")
require("config.edits")
require("config.explorer")
require("config.formatter")
require("config.lsp")
require("config.navigation")
require("config.sessions")
require("config.splash")
require("config.statusline")

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("mini.misc").setup_termbg_sync() -- Sync terminal background with nvim so it looks like it renders edge-to-edge
	end,
})
