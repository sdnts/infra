--------------------
-- Custom Actions --
--------------------

-- Move focus within Rex panes. If `nvim` is running, move focus within Neovim instead.
rex.action({
	name = "process_aware_pane_focus",
	title = "Focus Pane (Process-aware)",
	args = {
		type = "object",
		properties = {
			direction = { type = "string", enum = { "up", "down", "left", "right" } },
		},
	},
	run = function(ctx, args)
		local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
		if not process then error(err, 0) end

		if process.foreground and process.foreground.name == "nvim" then
			rex.client.queue("pane.send_key", { key = "ctrl+w" })
			rex.client.queue("pane.send_key", { key = args.direction })
		else
			rex.client.queue("pane.focus", { direction = args.direction, wrap = false })
		end
	end,
})

-- Split the active Rex pane. If `nvim` is running, split the Neovim pane instead.
rex.action({
	name = "process_aware_pane_split",
	title = "Split Pane (Process-aware)",
	args = {
		type = "object",
		properties = {
			direction = { type = "string", enum = { "down", "right" } },
		},
	},
	run = function(ctx, args)
		local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
		if not process then error(err, 0) end

		if process.foreground and process.foreground.name == "nvim" then
			rex.client.queue("pane.send_key", { key = "ctrl+w" })
			rex.client.queue("pane.send_key", { key = args.direction == "right" and "v" or "s" })
		else
			rex.client.queue("pane.split", { direction = args.direction })
		end
	end,
})

-- Close the active Rex pane. If `nvim` is running, close the Neovim pane instead.
rex.action({
	name = "process_aware_pane_close",
	title = "Close Pane (Process-aware)",
	run = function(ctx)
		local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
		if not process then error(err, 0) end

		if process.foreground and process.foreground.name == "nvim" then
			rex.client.queue("pane.send_key", { key = "ctrl+w" })
			rex.client.queue("pane.send_key", { key = "c" })
		else
			rex.client.queue("pane.close")
		end
	end,
})

--------------
-- Keybinds --
--------------

-- Sessions
rex.bind("cmd+s", "client.mode.enter", { name = "session", once = true })
rex.bind("session/cmd+s", "session.switch")
rex.bind("session/cmd+n", "session.new")
rex.bind("session/cmd+r", "session.rename")

-- Tabs
rex.bind("cmd+r", "client.tab.rename")

rex.bind("cmd+]", "client.tab.next")
rex.bind("cmd+[", "client.tab.previous")

-- Panes --
rex.bind("cmd+\\", "process_aware_pane_split", { direction = "right" })
rex.bind("cmd+-", "process_aware_pane_split", { direction = "down" })

rex.bind("cmd+up", "process_aware_pane_focus", { direction = "up" })
rex.bind("cmd+down", "process_aware_pane_focus", { direction = "down" })
rex.bind("cmd+left", "process_aware_pane_focus", { direction = "left" })
rex.bind("cmd+right", "process_aware_pane_focus", { direction = "right" })

rex.bind("cmd+shift+up", "pane.move.up")
rex.bind("cmd+shift+down", "pane.move.down")
rex.bind("cmd+shift+left", "pane.move.left")
rex.bind("cmd+shift+right", "pane.move.right")
rex.bind("cmd+shift+f", "pane.float")
rex.bind("cmd+shift+m", "pane.minimize_floating")

rex.bind("cmd+k", "pane.go_to")
rex.bind("cmd+z", "pane.zoom")
rex.bind("cmd+w", "process_aware_pane_close")

rex.bind("cmd+alt+f", "pane.new_floating")

rex.unbind("cmd+p") -- Unbound to allow Neovim to use it to open the file browser instead
