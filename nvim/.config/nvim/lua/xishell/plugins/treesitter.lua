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
    lazy = false, -- main branch does not support lazy-loading
    config = function()
        local ts = require("nvim-treesitter")
        -- main branch: setup() only takes install_dir, installs go through install()
        ts.install({
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
        })

        local disable_hl = { latex = true, bibtex = true, asm = true }
        local disable_indent = { asm = true }

        local function attach(buf, lang)
            if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(lang) then return end
            local ft = vim.bo[buf].filetype
            if not disable_hl[ft] then
                pcall(vim.treesitter.start, buf, lang)
            end
            -- without an indents query the expr returns 0 for every line; keep the Vim indent then
            if not disable_indent[ft] and vim.treesitter.query.get(lang, "indents") then
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang then return end
                if vim.treesitter.language.add(lang) then
                    attach(args.buf, lang)
                elseif vim.tbl_contains(ts.get_available(), lang) then
                    ts.install(lang):await(function() vim.schedule(function() attach(args.buf, lang) end) end)
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
