vim.g.preview = {
  -- typst = true,
  -- latex = true,
  -- markdown = true,
  html = {
    cmd = { 'true' },
    args = function()
      return {}
    end,
    output = function(ctx)
      return ctx.file
    end,
    open = true,
  },
}

vim.pack.add({
  'https://github.com/barrettruth/preview.nvim',
})
