-- Sessions
rex.bind("alt+s", "client.mode.enter", { name = "session", once = true })
rex.bind("session/alt+s", "session.switch")
rex.bind("session/alt+n", "session.new")
rex.bind("session/alt+r", "session.rename")

-- Tabs
rex.bind("alt+t", "client.tab.new")
rex.bind("alt+r", "client.tab.rename")

rex.bind("alt+]", "client.tab.next")
rex.bind("alt+[", "client.tab.previous")

rex.bind("alt+0", "client.palette.toggle")
rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })

-- Panes / Splits
rex.bind("alt+-", "pane.split", { direction = "down" })
rex.bind("alt+\\", "pane.split", { direction = "right" })

rex.bind("alt+f", "pane.float")
rex.bind("alt+z", "pane.zoom")
rex.bind("alt+=", "pane.balance")

rex.bind("alt+up", "pane.focus", { direction = "up", wrap = false })
rex.bind("alt+down", "pane.focus", { direction = "down", wrap = false })
rex.bind("alt+left", "pane.focus", { direction = "left", wrap = false })
rex.bind("alt+right", "pane.focus", { direction = "right", wrap = false })

rex.bind("alt+shift+up", "pane.move.up")
rex.bind("alt+shift+down", "pane.move.down")
rex.bind("alt+shift+left", "pane.move.left")
rex.bind("alt+shift+right", "pane.move.right")

-- rex.bind("alt+", "client.mode.enter", { name = "resize", once = true })
-- rex.bind("resize/up", "pane.resize", { direction = "up", amount = 2 })
-- rex.bind("resize/down", "pane.resize", { direction = "down", amount = 2 })
-- rex.bind("resize/left", "pane.resize", { direction = "left", amount = 2 })
-- rex.bind("resize/right", "pane.resize", { direction = "right", amount = 2 })

-- Neovim-specific
rex.unbind("cmd+w") -- Overridden to close neovim tabs instead of Rex tabs
rex.unbind("cmd+up") -- Overridden to navigate Neovim panes instead of Rex capturing it
rex.unbind("cmd+down") -- Overridden to navigate Neovim panes instead of Rex capturing it
rex.unbind("cmd+left") -- Overridden to navigate Neovim panes instead of Rex capturing it
rex.unbind("cmd+right") -- Overridden to navigate Neovim panes instead of Rex capturing it
rex.unbind("cmd+-") -- Overriden to create Neovim splits instead of zooming out
rex.unbind("cmd+z") -- Overridden to zoon Neovim panes instead of Rex undo
rex.unbind("cmd+enter") -- Overriden to accept Neovim AI suggestions instead of creating new Rex panes
