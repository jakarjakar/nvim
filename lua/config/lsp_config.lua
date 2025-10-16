require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "basedpyright" },
})
vim.lsp.enable({
	"basedpyright"
})


-- vim.diagnostic.config({
-- 	virtual_text = true,	
-- })

