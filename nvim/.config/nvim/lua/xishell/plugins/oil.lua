---@module "lazy"
---@type LazySpec
return {
    "stevearc/oil.nvim",
    dependencies = "echasnovski/mini.icons",

    lazy = false,
    init = function()
        -- Disable netrw to fully replace it with oil.nvim
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = false,
        columns = {
            "icon",
        },
        view_options = {
            show_hidden = true,
            is_always_hidden = function(name, _)
                return name == ".." or name == ".git"
            end,
        },
        win_options = {
            wrap = true,
            cursorcolumn = false,
        },
        watch_for_changes = true,
        use_default_keymaps = true,
        show_hidden = true,
    },
}
