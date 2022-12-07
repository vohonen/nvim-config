-- set encoding
vim.o.fileencoding = 'utf-8'

-- show row and relative row numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- change tab to 4 spaces width
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- disable autocommenting newlines
-- vim.opt.formatoptions = vim.opt.formatoptions - 'cro'
-- doesn't work still...
vim.cmd [[
	autocmd BufNewFile,Bufread * setlocal formatoptions-=cro
]]

-- always show n rows at the top and bottom
vim.o.scrolloff = 15

-- better autoindent
vim.o.smartindent = true
vim.o.autoindent = true

-- enable break indent; subsequent lines after breaking will be indented to the same level as the original
vim.o.breakindent = true
-- don't wrap long lines
-- vim.o.wrap=false

-- save undo history
vim.opt.undofile = true

-- case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- decrease update time
vim.o.updatetime = 250

-- show sign column for e.g. debugger break points
vim.wo.signcolumn = 'yes:1'

-- a little bit of potential extra colours
vim.o.termguicolors = true


-- treat hyphenated words as a single words
vim.cmd [[set iskeyword+=-]]
