-- TEST: Cyberdream engine recoloured toward Oxocarbon (softer fg, oxocarbon pink,
-- calmer purple, de-neoned green/yellow). Revert: git checkout <this file>
return {
	"scottmckendry/cyberdream.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("cyberdream").setup({
			variant = "default",
			colors = {
				bg = "#16181a",
				bg_alt = "#1e2124",
				fg = "#e2e4ea",
				grey = "#7b8496",
				blue = "#6ba5ff",
				green = "#83c995",
				cyan = "#52e6ec",
				red = "#ff6e5e",
				yellow = "#f0d070",
				magenta = "#ff7eb6",
				pink = "#ff5ea0",
				orange = "#ffb86c",
				purple = "#b87af2",
			},
		})
		vim.cmd.colorscheme("cyberdream")
	end,
}
