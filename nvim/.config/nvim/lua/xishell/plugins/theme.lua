-- tokyonight night, recoloured to Hearth (palette generated from theme/palette.toml)
return {
	"folke/tokyonight.nvim",
	name = "tokyonight",
	config = function()
		local e = require("xishell.ember")
		require("tokyonight").setup({
			style = "night",
			on_colors = function(c)
				c.bg, c.bg_dark, c.bg_dark1 = e.base, e.crust, e.crust
				c.bg_float, c.bg_popup, c.bg_sidebar, c.bg_statusline = e.crust, e.crust, e.crust, e.crust
				c.bg_highlight, c.bg_visual, c.bg_search = e.selection, e.surface, e.surface
				c.fg, c.fg_dark, c.fg_float, c.fg_sidebar = e.fg, e.fg_dim, e.fg, e.fg_dim
				c.fg_gutter, c.dark3, c.dark5, c.comment = e.overlay, e.overlay, e.comment, e.comment
				c.terminal_black = e.black_bright
				c.border, c.border_highlight = e.surface, e.primary
				-- Code: functions/dirs blue, types cyan, keywords magenta, strings green, attributes yellow
				c.blue, c.blue0, c.blue7 = e.blue, e.selection, e.surface
				c.blue1, c.blue2, c.blue5, c.blue6 = e.cyan, e.cyan, e.cyan, e.cyan_bright
				c.cyan, c.teal, c.green, c.green1, c.green2 = e.cyan, e.teal, e.green, e.teal, e.teal
				c.magenta, c.magenta2, c.purple = e.magenta, e.magenta_bright, e.magenta
				c.orange, c.yellow, c.red, c.red1 = e.orange, e.yellow, e.red, e.red
				c.git = { add = e.green, change = e.blue, delete = e.red, ignore = e.overlay }
			end,
			on_highlights = function(hl, c)
				-- Orange marks focus and matches
				hl.CursorLineNr = { fg = e.primary, bold = true }
				hl.Visual = { bg = e.primary, fg = e.crust } -- selection is a solid primary block
				hl.LineNr = { fg = e.overlay }
				hl.Search = { bg = e.surface, fg = e.primary, bold = true }
				hl.IncSearch = { bg = e.primary, fg = e.crust, bold = true }
				hl.CurSearch = hl.IncSearch
				hl.MatchParen = { fg = e.primary, bold = true }
				hl.FloatBorder = { fg = e.overlay, bg = c.bg_float }
			end,
		})
		vim.cmd([[colorscheme tokyonight-night]])
	end,
}
