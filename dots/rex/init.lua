-- Sessions
rex.bind("ctrl+0", "session.switch")
rex.bind("ctrl+n", "session.new")
rex.bind("ctrl+r", "session.rename")

-- Tabs
rex.bind("alt+t", "client.tab.new")
rex.bind("alt+r", "client.tab.rename")

rex.bind("alt+]", "client.tab.next")
rex.bind("alt+[", "client.tab.previous")

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

rex.bind("alt+up", "pane.focus", { direction = "up" })
rex.bind("alt+down", "pane.focus", { direction = "down" })
rex.bind("alt+left", "pane.focus", { direction = "left" })
rex.bind("alt+right", "pane.focus", { direction = "right" })

rex.bind("alt+shift+up", "pane.resize", { direction = "up", amount = 2 })
rex.bind("alt+shift+down", "pane.resize", { direction = "down", amount = 2 })
rex.bind("alt+shift+left", "pane.resize", { direction = "left", amount = 2 })
rex.bind("alt+shift+right", "pane.resize", { direction = "right", amount = 2 })

rex.bind("alt+z", "pane.zoom")
rex.bind("alt+=", "pane.balance")

-- Neovim-specific
rex.unbind("cmd+t")
rex.unbind("cmd+n")

rex.unbind("cmd+w")

rex.unbind("cmd+up")
rex.unbind("cmd+down")
rex.unbind("cmd+left")
rex.unbind("cmd+right")

rex.unbind("cmd+\\")
rex.unbind("cmd+-")

rex.unbind("cmd+z")

rex.unbind("cmd+e")
rex.unbind("cmd+shift+f")
rex.unbind("cmd+s")
rex.unbind("cmd+shift+s")

rex.unbind("cmd+p")
rex.unbind("cmd+.")
rex.unbind("cmd+enter")
rex.unbind("cmd+shift+enter")
