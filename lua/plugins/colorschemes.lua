-- gruvbuddy specific
-- require('colorbuddy').colorscheme('gruvbuddy')

local colorscheme = 'system76'

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end

-- require('nightfox').load('nightfox')
-- lualine
require('lualine').setup {
  options = { theme  = 'onedark' },
}

