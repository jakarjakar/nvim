-- Open a Jira work item in jiratui (TUI) inside a toggleterm float.
-- <leader>uj in normal mode: key under the cursor (e.g. MNTPTL-428, M30-1114).
-- <leader>uj in visual mode: the selected text.
-- :Jira [KEY] — same, KEY defaults to the word under the cursor.
local Terminal = require("toggleterm.terminal").Terminal

local KEY_PATTERN = "%u[%u%d]*%-%d+"

local function extract_key(text)
	return text and text:match(KEY_PATTERN) or nil
end

local function key_under_cursor()
	return extract_key(vim.fn.expand("<cWORD>"))
end

local function visual_selection()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	return table.concat(lines, " ")
end

local function open(key)
	if vim.fn.executable("jiratui") == 0 then
		vim.notify("jiratui not found in $PATH", vim.log.levels.ERROR)
		return
	end
	if not key then
		vim.notify("No Jira key (PROJECT-123) found", vim.log.levels.WARN)
		return
	end
	Terminal:new({
		cmd = "jiratui ui --work-item-key " .. key,
		hidden = true,
		direction = "float",
		close_on_exit = true,
		count = 98, -- next to k9s (99), away from <C-\> (count 1)
		float_opts = {
			border = "curved",
			width = math.floor(vim.o.columns * 0.9),
			height = math.floor(vim.o.lines * 0.85),
		},
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.wo[term.window].number = false
			vim.wo[term.window].relativenumber = false
			vim.wo[term.window].signcolumn = "no"
			-- jiratui owns <esc>; <C-q> closes the float
			vim.keymap.set("t", "<C-q>", function()
				term:close()
			end, { buffer = term.bufnr, desc = "Close jiratui" })
		end,
	}):open()
end

vim.api.nvim_create_user_command("Jira", function(cmd)
	open(extract_key(cmd.args ~= "" and cmd.args or nil) or key_under_cursor())
end, { nargs = "?", desc = "Open Jira work item in jiratui" })

vim.keymap.set("n", "<leader>uj", function()
	open(key_under_cursor())
end, { desc = "Jira: open key under cursor" })

vim.keymap.set("x", "<leader>uj", function()
	local key = extract_key(visual_selection())
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	open(key)
end, { desc = "Jira: open selected key" })
