vim.pack.add({
	"https://github.com/akinsho/toggleterm.nvim",
})

-- Paste system clipboard into terminal with Cmd+V
vim.keymap.set("t", "<D-v>", function()
  -- Try yank register first (last explicit yank in Neovim), fall back to system clipboard
  local text = vim.fn.getreg("0")
  if text == "" then
    text = vim.fn.getreg("+")
  end
  vim.api.nvim_feedkeys(text, "t", false)
end, { desc = "Paste clipboard in terminal" })

require("toggleterm").setup{
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
	 border = "curved",
	 winblend = 0,
	 highlights = {
	  border = "Normal",
	  background = "Normal",
	 },
	},
}
