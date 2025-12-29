vim.pack.add({
	"https://github.com/folke/tokyonight.nvim",
})
require("tokyonight").setup({
  transparent = true,  -- Disables background color for editor
  styles = {
    sidebars = "transparent",  -- Sidebars/floats also transparent
    floats = "transparent",
  },
})

vim.cmd[[colorscheme tokyonight]]
