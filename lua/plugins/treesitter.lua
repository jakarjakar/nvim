return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,           -- disable lazy loading for this plugin
    build = ":TSUpdate",    -- update Treesitter parsers automatically after install
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "lua", "javascript" }, -- languages to install
        highlight = { enable = true },  -- enable syntax highlighting
        indent = { enable = true },     -- optionally enable indent
      })
    end,
  },
}
