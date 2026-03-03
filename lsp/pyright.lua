-- vim.lsp.config('pyright', {
--   cmd = { 'pyright-langserver', '--stdio' },
--   settings = {
--     python = {
--       analysis = {
--         diagnosticMode = 'workspace',
--         autoSearchPaths = true,
--         useLibraryCodeForTypes = true,
--       },
--     },
--   },
--   filetypes = { 'python' },
-- })
return {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}

