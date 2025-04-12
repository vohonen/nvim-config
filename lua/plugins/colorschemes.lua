-- gruvbuddy specific
-- require('colorbuddy').colorscheme('gruvbuddy')

local colorscheme = 'system76'

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end

require('lualine').setup {

	options = {
	theme = 'onedark',
	section_separators = '',
	component_separators = '',
	disabled_filetypes = { 'NvimTree' },
	},

	-- status line already set 
	-- options for tabs at the top
	tabline = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
		  {
			'buffers',
			show_filename_only = true,       -- Show only filename instead of relative path
			hide_filename_extension = false, -- Show file extensions
			show_modified_status = true,     -- Shows [+] if file is modified
			mode = 2,                        -- 0: Shows buffer name
											 -- 1: Shows buffer index
											 -- 2: Shows buffer name + buffer index
			max_length = vim.o.columns,      -- Maximum width of buffers component
			symbols = {
			  modified = ' [+]',             -- Shows when file is modified
			  alternate_file = '',           -- Hide alternate file symbol
			  directory = '',                -- Hide directory
			},
		  }
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {}
	},
}
