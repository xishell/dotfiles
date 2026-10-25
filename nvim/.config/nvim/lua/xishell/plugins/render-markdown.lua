---@module "lazy"
---@type LazySpec

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        completions = { blink = { enabled = true } },
        -- snacks.image renders math as real pdflatex images
        latex = { enabled = false },
        heading = { position = "inline", width = "block" },
        code = { width = "block", min_width = 45, language_pad = 1 },
        checkbox = { position = "inline" },
    },
    keys = {
        { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle Markdown Render" },
    },
}
