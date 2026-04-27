---@module "lazy"
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        "windwp/nvim-ts-autotag",
    },
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    config = function()
        require("nvim-treesitter").setup({
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
                "html",
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
            auto_install = true,
        })

        -- Enable treesitter highlight and indent (now built-in to Neovim)
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local disable_hl = { latex = true, bibtex = true, asm = true }
                local disable_indent = { asm = true }
                local ft = vim.bo[args.buf].filetype
                local lang = vim.treesitter.language.get_lang(ft)
                if not lang then return end
                local ok = pcall(vim.treesitter.language.add, lang)
                if not ok then return end
                if not disable_hl[ft] then
                    pcall(vim.treesitter.start, args.buf, lang)
                end
                if not disable_indent[ft] then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        -- Incremental selection via treesitter nodes
        local node_stack = {}
        vim.keymap.set("n", "<C-space>", function()
            local node = vim.treesitter.get_node()
            if not node then return end
            node_stack = { node }
            local sr, sc, er, ec = node:range()
            vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
            vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
            vim.cmd("normal! gv")
        end, { desc = "Increment Selection" })

        vim.keymap.set("x", "<C-space>", function()
            local node = node_stack[#node_stack]
            if not node then return end
            local parent = node:parent()
            if not parent then return end
            node_stack[#node_stack + 1] = parent
            local sr, sc, er, ec = parent:range()
            vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
            vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
            vim.cmd("normal! gv")
        end, { desc = "Increment Selection" })

        vim.keymap.set("x", "<bs>", function()
            if #node_stack <= 1 then
                vim.cmd("normal! \27") -- escape
                return
            end
            table.remove(node_stack)
            local node = node_stack[#node_stack]
            local sr, sc, er, ec = node:range()
            vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
            vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
            vim.cmd("normal! gv")
        end, { desc = "Decrement Selection" })
    end,
}
