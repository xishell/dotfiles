return {
	ensure_installed = {
		-- LSP servers
		"lua-language-server",
		"ltex-ls",
		"clangd",
		"tinymist",
		"gopls",
		"typescript-language-server",
		-- "asm-lsp", -- Disabled: Causes conflicts with RISC-V syntax

		-- Formatters
		"stylua",
		"prettierd",
		"shfmt",
		"black",
		"isort",
		"clang-format",
		"google-java-format",
		"gofumpt",
		"goimports-reviser",
		"rustfmt",
		"taplo",
		"sql-formatter",

		-- Linters
		"eslint_d",
		"ruff",
		"shellcheck",
		"markdownlint",
		"yamllint",
		"jsonlint",
		"golangci-lint",

		-- Build tools
		"make",
	},
	auto_update = false,
	run_on_start = true,
}
