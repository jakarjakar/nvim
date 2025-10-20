require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "basedpyright", "ruff" },
})
vim.lsp.enable({
	"basedpyright",
})
vim.diagnostic.config({
	virtual_text = true,
})
