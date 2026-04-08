return {
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/ruff"), "server" },
  filetypes = { "python" },
  root_markers = { "pyrightconfig.json", "pyproject.toml", "ruff.toml", ".git" },
}
