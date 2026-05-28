-- Install markdown-preview.nvim
vim.pack.add({ "https://github.com/iamcco/markdown-preview.nvim" })

-- Build plugin dependencies (requires yarn)
vim.fn["mkdp#util#install"]()

-- Load the plugin (it's in opt/, so needs explicit loading)
vim.cmd("packadd markdown-preview.nvim")

-- Optional: disable auto-start
vim.g.mkdp_auto_start = 0
