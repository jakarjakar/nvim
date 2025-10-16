return {
    'johnfrankmorgan/whitespace.nvim',
    config = function ()
        require('whitespace-nvim').setup({
            highlight = 'DiffDelete',
            ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help', 'dashboard' },
            ignore_terminal = true,
            return_cursor = true,
        })
        -- remove trailing whitespace with a keybinding
        -- vim.keymap.set('n', '<Leader>t', require('whitespace-nvim').trim)
    end
}
