return {
	{
		"folke/which-key.nvim",
		keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
		cmd = "WhichKey",
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				{ "<leader>b", group = "Buffer" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Database" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>gh", group = "Git Hunks" },
				{ "<leader>n", group = "Notes" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>s", group = "Search" },
				{ "<leader>t", group = "Test" },
				{ "<leader>u", group = "UI/Toggle" },
				{ "<leader>w", group = "Window/Write" },
				{ "<leader><tab>", group = "Tabs" },
			})
		end,
	},
}
