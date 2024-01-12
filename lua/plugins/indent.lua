
-- vim.opt.termguicolors = true
-- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#606060 blend=nocombine]]
-- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#606060 blend=nocombine]]
-- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#606060 blend=nocombine]]
-- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#606060 blend=nocombine]]
-- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#606060 blend=nocombine]]
-- vim.cmd [[highlight IndentBlanklineIndent6 guifg=#606060 blend=nocombine]]

-- vim.opt.listchars = {
--     space = "⋅",
--     eol = "↴",
-- }

-- require('indent_blankline').setup {
-- 	space_char_blankline = ' ',
-- 	filetype_exclude = { 'help', 'packer' },
-- 	buftype_exclude = { 'terminal', 'nofile' },
-- 	char_highlight = 'LineNr',
-- 	show_trailing_blankline_indent = false,
-- 	char_highlight_list = {
-- 		'IndentBlanklineIndent1',
-- 		'IndentBlanklineIndent2',
-- 		'IndentBlanklineIndent3',
-- 		'IndentBlanklineIndent4',
-- 		'IndentBlanklineIndent5',
-- 		'IndentBlanklineIndent6',
-- 	},
-- }

local highlight = {
	"browngrey",
	"browngrey",
	"browngrey",
	"browngrey",
	"browngrey",
	"browngrey",
	"browngrey",
}

local hooks = require "ibl.hooks"
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, 'browngrey', { fg = "#606060" })
end)

require("ibl").setup { indent = { 
	highlight = highlight,
	char = "▏"
	} 
}
