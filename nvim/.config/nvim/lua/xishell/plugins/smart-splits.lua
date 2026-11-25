return {
	{
		"mrjones2014/smart-splits.nvim",
		-- not lazy, kitty needs the IS_NVIM user var set as soon as nvim starts
		lazy = false,
		-- set the IS_NVIM kitty user var so --when-focus-on passes ctrl+hjkl to nvim
		init = function()
			local function setvar(v)
				io.stdout:write(("\27]1337;SetUserVar=IS_NVIM=%s\7"):format(v))
			end
			vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, { callback = function() setvar("MQ==") end })
			vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, { callback = function() setvar("") end })
		end,
		opts = {
			move = {
				-- past the last nvim split, step into the neighbouring kitty pane
				at_edge = function(ctx)
					local sock = vim.env.KITTY_LISTEN_ON
					if sock then
						local dir = { left = "left", right = "right", up = "top", down = "bottom" }
						vim.system({ "kitty", "@", "--to", sock, "action", "neighboring_window", dir[ctx.direction] })
					end
				end,
			},
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
