

-- https://tduyng.com/blog/neovim-basic-setup/
local opt = vim.opt

-- Behavior settings
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
