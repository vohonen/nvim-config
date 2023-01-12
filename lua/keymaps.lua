-- remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- toggle search highlighting
vim.api.nvim_set_keymap('n', '<leader>h', ':set hlsearch!<CR>', { noremap = true, silent = true })

-- copy, cut and paste with system register
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-x>', '"+d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-v>', '"+P', { noremap = false, silent = true })

-- close vertically split buffers without removing the split 
vim.api.nvim_set_keymap('n', '<leader>bd', ':bp<bar>vsp<bar>bn<bar>bd<CR>', { noremap = true, silent = true })

-- go to the end of the file and move line to the center of the screen
-- workaround because the scrolloff option isn't working
vim.api.nvim_set_keymap('n', '<leader><S-g>', '<S-g>zz', { noremap = true, silent = true })

-- better window movement
vim.api.nvim_set_keymap('n', '<S-h>', '<C-w>h', { silent = true })
vim.api.nvim_set_keymap('n', '<S-j>', '<C-w>j', { silent = true })
vim.api.nvim_set_keymap('n', '<S-k>', '<C-w>k', { silent = true })
vim.api.nvim_set_keymap('n', '<S-l>', '<C-w>l', { silent = true })

-- insert and append one character in normal mode
vim.api.nvim_set_keymap('n', ',i', 'i,<Esc>r', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ',a', 'a,<Esc>r', { noremap = true, silent = true })

-- tab switch buffers
vim.api.nvim_set_keymap('n', '<TAB>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-TAB>', ':bprevious<CR>', { noremap = true, silent = true })

-- insert a new line with Enter from normal mode
vim.api.nvim_set_keymap('n', '<CR>', 'o<Esc>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><CR>', 'O<Esc>j', { noremap = true, silent = true })

-- save and quit with leader
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>wq', ':wq<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>wa', ':wqa<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>qq', ':q!<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>qa', ':qa!<CR>', {noremap = true})

-- nvim-tree toggle
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', {noremap = true})

-- Git mappings
vim.api.nvim_set_keymap('n', '<Leader>gaa', ':G add .<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>gc', ':G commit<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>gp', ':G push<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>gaw', ':G add .<bar> :G commit <CR>', {noremap = true})

-- quote and bracket completion
-- vim.api.nvim_set_keymap('i', '"', '""<left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "'", "''<left>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '(', '()<left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '[', '[]<left>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '{', '{}<left>', { noremap = true, silent = true })
-- extra for {} with enter and tab indentation
-- vim.api.nvim_set_keymap('i', '{<CR>', '{<CR>}<ESC>O', { noremap = true, silent = true })

-- GNU make shortcuts
vim.api.nvim_set_keymap('n', '<leader>mm', ':!make<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ma', ':!make all<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>mc', ':!make clean<CR>', { noremap = true, silent = true })
-- for PAT course in Aalto
vim.api.nvim_set_keymap('n', '<leader>mpat',
	':!g++ -O3 -Werror -Wall --pedantic -std=c++17 -march=native -fopenmp -o %:r % && ./%:r<CR>',
	{ noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>mdb',
	':!g++ -ggdb -O0 -Werror -Wall -fsanitize=address --pedantic -std=c++17 -march=native -fopenmp -o %:r.db %<CR>',
	{ noremap = true, silent = true })

-- shortcut to show date
vim.api.nvim_set_keymap('n', '<leader>da', ':!date<CR>', { noremap = true})
