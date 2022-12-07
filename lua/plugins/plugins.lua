
------------------------ packer setup ------------------------

-- automatically ensure that packer.nvim is installed on any machine you clone your configuration
-- https://github.com/wbthomason/packer.nvim#bootstrapping
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

-- configure Neovim to automatically run :PackerCompile whenever plugins.lua is updated
-- end of https://github.com/wbthomason/packer.nvim#quickstart
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])



------------------------ packages ------------------------

-- https://github.com/wbthomason/packer.nvim#quickstart
require('packer').startup(function()
	-- packer can manage itself
	use 'wbthomason/packer.nvim'

	-- quality of life packages
	use 'nvim-treesitter/nvim-treesitter'										-- better syntax highlighting
	use {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}}	-- UI to find and open files
	use {'tpope/vim-commentary'} 												-- better commenting
	use 'lukas-reineke/indent-blankline.nvim'									-- indentation guides
	use 'ggandor/lightspeed.nvim'												-- faster jumping around
	use 'windwp/nvim-autopairs'													-- close pairs
	use {'kyazdani42/nvim-web-devicons'}										-- nice icons
	use {'kyazdani42/nvim-tree.lua'}--,											-- file explorer
		-- config = function() require'nvim-tree'.setup {} end
	-- }

	-- git packages
	use {'tpope/vim-fugitive'} 													-- git commands with :G
	use {'mhinz/vim-signify'} 													-- highlight changes
	use {'tpope/vim-rhubarb'} 													-- access files in Github

	-- LSP packages
	use {'neovim/nvim-lspconfig'}												-- configs for LSP client
	use {'williamboman/nvim-lsp-installer'} 									-- LSP install commands & GUI

	-- autocompletion
	use 'hrsh7th/nvim-cmp' 														-- autocompletion plugin
	use 'hrsh7th/cmp-nvim-lsp' 													-- LSP source for nvim-cmp
	use 'hrsh7th/cmp-buffer' 													-- buffer completions
	use 'hrsh7th/cmp-path' 														-- path completions
	use 'hrsh7th/cmp-cmdline' 													-- command line completions
	use 'saadparwaiz1/cmp_luasnip' 												-- snippets source for nvim-cmp

	-- snippets
	use 'L3MON4D3/LuaSnip' 														-- snippets plugin
	use 'rafamadriz/friendly-snippets'											-- bunch of snippets to use and modify

	-- latex support
	use 'lervag/vimtex'

	-- thematic and visual packages
	use 'lunarvim/colorschemes'													-- colorschemes with vimscript
	use {'nvim-lualine/lualine.nvim',											-- fancier statusline
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}
	-- specific colorschemes
	use 'EdenEast/nightfox.nvim'
	use 'joshdick/onedark.vim'
	use {'tjdevries/colorbuddy.nvim'} 											-- theme with more number contrast
	use {'tjdevries/gruvbuddy.nvim'} 											-- theme with more number contrast

end)

