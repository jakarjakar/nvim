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
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/pyright-langserver"), "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", ".git" },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
}

