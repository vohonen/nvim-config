vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', { noremap = true, silent = true })

-- Open preview in a new Firefox window
-- vim.g.mkdp_browser = 'firefox --new-window'
vim.g.mkdp_browser = 'firefox -P default --new-instance'

-- Auto-start preview when opening markdown files
vim.g.mkdp_auto_start = 0

-- Auto-close preview when switching buffers
vim.g.mkdp_auto_close = 1

-- Refresh on save or leaving insert mode
vim.g.mkdp_refresh_slow = 0

-- Browser to use (or leave empty for default)
vim.g.mkdp_browser = ''

-- Preview theme (dark or light)
vim.g.mkdp_theme = 'dark'
