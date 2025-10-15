return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",           -- Switch from "master" to "main"
  lazy = false,              -- nvim-treesitter does not support lazy loading
  build = ":TSUpdate",       -- Ensure parsers update after install
}

