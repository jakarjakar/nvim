return {
	"akinsho/toggleterm.nvim",
	version = "*", -- use latest stable release
	config = function()
		require("toggleterm").setup({
			size = 20,
			open_mapping = [[<c-\>]], -- default mapping
			hide_numbers = true,
			shade_filetypes = {},
			shading_factor = 2,
			start_in_insert = true,
			persist_size = true,
			direction = "float", -- "vertical" | "horizontal" | "tab" | "float"
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 3,
			},
		})

		-- Keymaps for convenience
		vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
		vim.keymap.set(
			"n",
			"<leader>tv",
			"<cmd>ToggleTerm size=80 direction=vertical<CR>",
			{ desc = "Vertical terminal" }
		)
		vim.keymap.set(
			"n",
			"<leader>th",
			"<cmd>ToggleTerm size=15 direction=horizontal<CR>",
			{ desc = "Horizontal terminal" }
		)
	end,
}
