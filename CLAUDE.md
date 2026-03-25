# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **Neovim's built-in package manager** (`vim.pack.add`) — not lazy.nvim or packer. It targets Neovim nightly (0.12+) which ships `vim.pack` natively.

## Architecture

```
init.lua                  # Entry point: options, loads config/* and plugins/*
lua/
  config/
    keymaps.lua           # All global keymaps
    lsp.lua               # LSP attach autocmd, inlay hints, default LSP keymaps
    init.lua              # Minimal extra options (clipboard)
  plugins/
    init.lua              # Requires all plugin files in order
    snacks.lua            # snacks.nvim setup + claudecode.nvim + bulk keymaps
    whichkey.lua          # which-key groups and additional keymaps
    mason.lua             # mason.nvim (LSP installer)
    nvim-lspconfig.lua    # nvim-lspconfig (just adds the package)
    toggleterm.lua        # toggleterm.nvim (float terminal, <C-\>)
    lazygit.lua           # lazygit.nvim
    tokyonight.lua        # colorscheme (transparent)
lsp/
  pyright.lua             # Pyright LSP config (loaded by vim.lsp.enable)
```

## Plugin Management

All plugins are installed via `vim.pack.add("https://github.com/...")` — Neovim's native package manager. There is no lockfile management beyond `nvim-pack-lock.json`.

## LSP Setup

LSP is configured in two places:
- `lua/config/lsp.lua`: The `LspAttach` autocmd that sets keymaps and enables inlay hints/document colors. Servers are enabled via `vim.lsp.enable({...})`.
- `lsp/pyright.lua`: Per-server config files (Neovim 0.11+ native LSP config format). Active servers: `pyright`, `stylua`.

To add a new LSP server: create `lsp/<servername>.lua` with a config table, then add it to `vim.lsp.enable({})` in `lua/config/lsp.lua`.

On-demand LSP loading is supported: set `vim.g.lsp_on_demands = {"eslint"}` before startup.

## Key Conventions

- **Leader key**: `<Space>`
- **Completion**: `blink.cmp` (or native via `vim.g.completion_mode = "native"`)
- **File picker / grep / LSP navigation**: All routed through `snacks.nvim` picker (`<leader><space>`, `<leader>/`, `gd`, `gr`, etc.)
- **Terminal**: Both `toggleterm` (`<C-\>`) and `snacks.terminal` (`<C-/>`) are configured
- **Claude AI**: `claudecode.nvim` under `<leader>a*` — toggle (`<leader>ac`), focus (`<leader>af`), add buffer (`<leader>ab`), send selection (`<leader>as`)

## Adding Plugins

1. Call `vim.pack.add({"https://github.com/author/plugin.nvim"})` at the top of a new file in `lua/plugins/`
2. Add `require("plugins.yourplugin")` to `lua/plugins/init.lua`
