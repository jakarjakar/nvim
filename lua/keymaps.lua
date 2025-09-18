local opts = { silent = true }

local function opt(desc, others)
  return vim.tbl_extend("force", opts, { desc = desc }, others or {})
end

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Shorten function name
local keymap = vim.keymap.set

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

keymap("n", "<Leader>w", function()
  vim.cmd("silent! write!")
  vim.notify("File saved")
end, opt("Save"))
keymap("n", "<Leader>q", "<Cmd>q!<CR>", opt("Quit"))
keymap("n", "<Leader>c", "<Cmd>bd!<CR>", opt("Close"))
keymap("n", "<Leader>h", "<cmd>noh<CR>")
