return {
	settings = {
		typescript = {
			tsserver = {
				maxTsServerMemory = 8192,
				experimental = { useTsgo = true },
				watchOptions = {
					watchFile = "useFsEventsOnParentDirectory",
					fallbackPolling = "dynamicPriorityPolling",
				},
			},
		},
	},
}
