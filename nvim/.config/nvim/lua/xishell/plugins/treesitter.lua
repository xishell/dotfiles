---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-textobjects",
        "windwp/nvim-ts-autotag",
    },
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
        { "<c-space>", desc = "Increment Selection" },
        { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            modules = {},
            sync_install = false,
            ignore_install = {},
            auto_install = true,
            autotag = {
                enable = true,
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
                disable = {
                    "latex",
                    "bibtex",
                    "asm", -- Disable treesitter for assembly files to avoid parsing issues
                }
            },
            indent = {
                enable = true,
                disable = { "asm" }, -- Disable treesitter indent for assembly
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            ensure_installed = {
                "bash",
                "bibtex",
                "c",
                "comment",
                "diff",
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "java",
                "javascript",
                "jsdoc",
                "json",
                "latex",
                "lua",
                "luadoc",
                "make",
                "markdown",
                "markdown_inline",
                "norg",
                "python",
                "regex",
                "toml",
                "tsx",
                "typescript",
                "typst",
                "vim",
                "vimdoc",
                "yaml",
            },
        })
    end,
}
