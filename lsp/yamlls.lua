return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  settings = {
    yaml = {
      schemas = {},
      validate = true,
      hover = true,
      completion = true,
    },
  },
}