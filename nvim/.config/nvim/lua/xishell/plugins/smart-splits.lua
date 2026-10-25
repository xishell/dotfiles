return {
	{
		"mrjones2014/smart-splits.nvim",
		-- not lazy, kitty needs the IS_NVIM user var set as soon as nvim starts
		lazy = false,
		opts = {
			-- Past the last nvim split and kitty split, step into the next Hyprland
			-- window; elsewhere (macOS) keep the default wrap
			at_edge = function(ctx)
				if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
					vim.system({ "hyprctl", "eval", ('hl.dispatch(hl.dsp.focus({ direction = "%s" }))'):format(ctx.direction) })
				else
					ctx.wrap()
				end
			end,
		},
		keys = {
			{ "<c-h>", function() require("smart-splits").move_cursor_left() end },
			{ "<c-j>", function() require("smart-splits").move_cursor_down() end },
			{ "<c-k>", function() require("smart-splits").move_cursor_up() end },
			{ "<c-l>", function() require("smart-splits").move_cursor_right() end },
			{ "<c-\\>", function() require("smart-splits").move_cursor_previous() end },
		},
	},
}
