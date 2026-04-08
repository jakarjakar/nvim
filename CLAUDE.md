# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **Neovim's built-in package manager** (`vim.pack.add`) — not lazy.nvim or packer. It targets **Neovim 0.12**, which ships `vim.pack` natively.

## Architecture

```
init.lua                  # Entry point: options, filetype map, loads config/* and plugins/*
lua/
  config/
    keymaps.lua           # All global keymaps
    lsp.lua               # LspAttach autocmd, inlay hints, format-on-save, vim.lsp.enable()
    init.lua              # SSH clipboard detection
  plugins/
    init.lua              # Requires all plugin files in order
    snacks.lua            # snacks.nvim setup + claudecode.nvim + bulk keymaps
    whichkey.lua          # which-key groups and additional keymaps
    mason.lua             # mason.nvim (LSP installer UI)
    nvim-lspconfig.lua    # nvim-lspconfig (package only, config lives in lsp/)
    toggleterm.lua        # toggleterm.nvim (float terminal, <C-\>)
    lazygit.lua           # lazygit.nvim
    tokyonight.lua        # colorscheme (transparent)
    csvview.lua           # csvview.nvim
lsp/
  pyright.lua             # Python LSP (mason bin, root markers, settings)
  ruff.lua                # Ruff LSP (formatter/linter for Python)
  yamlls.lua              # YAML LSP
  gitlab_ci_ls.lua        # GitLab CI LSP (filetype: yaml.gitlab)
```

## Plugin Management

All plugins are installed via `vim.pack.add("https://github.com/...")` — Neovim's native package manager. Lockfile: `nvim-pack-lock.json`.

## LSP Setup

LSP is configured in two places:
- `lua/config/lsp.lua`: `LspAttach` autocmd (keymaps, inlay hints, document colors), format-on-save, and `vim.lsp.enable({...})`.
- `lsp/<server>.lua`: Per-server config files (Neovim 0.11+ native format).

Active servers: `pyright`, `ruff`, `stylua`, `yamlls`, `gitlab_ci_ls`.

**Format on save**: ruff for Python files, LSP fallback for everything else (see `lua/config/lsp.lua`).

**To add a new LSP server**: create `lsp/<servername>.lua` with a config table, then add it to `vim.lsp.enable({})` in `lua/config/lsp.lua`.

**On-demand servers**: set `vim.g.lsp_on_demands = {"eslint"}` before startup.

## Key Conventions

- **Leader key**: `<Space>`
- **Completion**: native (`vim.g.completion_mode = "native"` in `lua/config/lsp.lua`; switch to `"blink"` to use blink.cmp)
- **File picker / grep / LSP navigation**: all through `snacks.nvim` picker — `<leader><space>`, `<leader>/`, `gd`, `gr`, etc.
- **Terminal**: `toggleterm` (`<C-\>`) and `snacks.terminal` (`<C-/>`)
- **Claude AI**: `claudecode.nvim` under `<leader>a*` — toggle (`<leader>ac`), focus (`<leader>af`), add buffer (`<leader>ab`), send selection (`<leader>as`)
- **`gd`**: goes to LSP definition; falls back to pytest fixture search for Python (see `lua/config/keymaps.lua`)

## Quick Tweaks Reference

| What to change | Where |
|---|---|
| Editor options (tabs, numbers, mouse, folds…) | `init.lua` top section |
| Colorscheme / transparency | `lua/plugins/tokyonight.lua` |
| Completion mode (native ↔ blink) | `vim.g.completion_mode` in `lua/config/lsp.lua` |
| Add/remove LSP server | `lsp/<server>.lua` + `vim.lsp.enable()` in `lua/config/lsp.lua` |
| Format-on-save logic | `lua/config/lsp.lua` — `BufWritePre` autocmd |
| Keymaps | `lua/config/keymaps.lua` (global), `lua/plugins/snacks.lua` (picker/UI), `lua/plugins/whichkey.lua` (groups) |
| Snacks features (indent, scroll, zen…) | `lua/plugins/snacks.lua` → `opts.styles` / feature keys |
| Picker ignore patterns | `lua/plugins/snacks.lua` → `opts.picker.ignored` |
| Filetype detection (.env, .gitlab-ci…) | `init.lua` → `vim.filetype.add` block |
| Terminal float style | `lua/plugins/toggleterm.lua` |
| Add a plugin | `lua/plugins/<name>.lua` + `require` in `lua/plugins/init.lua` |

## Adding Plugins

1. Create `lua/plugins/<name>.lua` — call `vim.pack.add({"https://github.com/author/plugin.nvim"})` at the top.
2. Add `require("plugins.<name>")` to `lua/plugins/init.lua`.
