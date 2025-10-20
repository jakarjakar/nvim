return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional for icons
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Fzf Find Files" })
		vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Fzf Live Grep" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Fzf Buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Fzf Help Tags" })
	end,
}
