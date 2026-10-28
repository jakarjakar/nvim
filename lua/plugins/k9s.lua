-- k9s in a floating terminal: the full RBAC-aware cluster browser.
-- Complements kubectl.nvim (<leader>8) — this one covers every resource kind
-- (ConfigMaps, Secrets, CRDs…) and edits in place with `e`.
local Terminal = require("toggleterm.terminal").Terminal

local k9s = Terminal:new({
	cmd = "k9s",
	hidden = true,
	direction = "float",
	close_on_exit = true,
	count = 99, -- keep out of the way of <C-\> (count 1)
	env = {
		-- `e` inside k9s opens a nested nvim in this float; :wq applies, :cq aborts
		KUBE_EDITOR = "nvim",
		EDITOR = "nvim",
	},
	float_opts = { border = "curved", width = math.floor(vim.o.columns * 0.9), height = math.floor(vim.o.lines * 0.85) },
	on_open = function(term)
		vim.cmd("startinsert!")
		vim.wo[term.window].number = false
		vim.wo[term.window].relativenumber = false
		vim.wo[term.window].signcolumn = "no"
		-- k9s owns <esc> and <C-\>; only <C-q> closes the float
		vim.keymap.set("t", "<C-q>", function()
			term:toggle()
		end, { buffer = term.bufnr, desc = "Close k9s" })
	end,
})

local function toggle()
	if vim.fn.executable("k9s") == 0 then
		vim.notify("k9s not found in $PATH (brew install k9s)", vim.log.levels.ERROR)
		return
	end
	k9s:toggle()
end

vim.api.nvim_create_user_command("K9s", toggle, { desc = "Toggle k9s float" })
vim.keymap.set("n", "<leader>9", toggle, { desc = "k9s cluster browser" })
