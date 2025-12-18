local map = vim.keymap.set

--better ESC                            
map("i", "jk", "<ESC>")


--git
map("n", "<leader>gg", ":LazyGit<CR>", { desc = "LazyGit" })

