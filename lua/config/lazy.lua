
------------------------ lazy.nvim setup ------------------------
-- https://lazy.folke.io/installation 
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


------------------------ packages ------------------------

-- https://github.com/wbthomason/packer.nvim#quickstart
-- require('packer').startup(function()
	-- packer can manage itself
	-- use 'wbthomason/packer.nvim'

local plugins = {

	-- quality of life packages
	 {'nvim-treesitter/nvim-treesitter'},			-- better syntax highlighting
	 -- {'nvim-telescope/telescope.nvim', 			-- UI to find and open files
		-- dependencies = {'nvim-lua/plenary.nvim'}
	 -- },	
	 {'tpope/vim-commentary'}, 					-- better commenting
	 {'lukas-reineke/indent-blankline.nvim'},		-- indentation guides
	 {'ggandor/lightspeed.nvim'},					-- faster jumping around
	 {'windwp/nvim-autopairs'},					-- close pairs
	 {'tpope/vim-surround'},					-- surround text with smth
	 {'kyazdani42/nvim-web-devicons'},			-- nice icons
	 {'kyazdani42/nvim-tree.lua'},				-- file explorer
		-- config = function() require'nvim-tree'.setup {} end
	-- }

	-- git packages
	 {'tpope/vim-fugitive'}, 						-- git commands with :G
	 {'mhinz/vim-signify'},						-- highlight changes
	 {'tpope/vim-rhubarb'},						-- access files in Github

	-- LSP packages
	 {'williamboman/mason.nvim',					-- interface for managing LSP
		build = ":MasonUpdate"},					
     {'williamboman/mason-lspconfig.nvim'},		-- wrapper between Mason and lspconfig
	 {'neovim/nvim-lspconfig'},					-- configs for LSP client
	 -- {'williamboman/nvim-lsp-installer'},		-- LSP install commands & GUI

	-- autocompletion
	 {'hrsh7th/nvim-cmp'}, 						-- autocompletion plugin
	 {'hrsh7th/cmp-nvim-lsp'}, 					-- LSP source for nvim-cmp
	 {'hrsh7th/cmp-buffer'},						-- buffer completions
	 {'hrsh7th/cmp-path'},						-- path completions
	 {'hrsh7th/cmp-cmdline'},					-- command line completions
	 {'saadparwaiz1/cmp_luasnip'},				-- snippets source for nvim-cmp

	-- snippets
	 {'L3MON4D3/LuaSnip'},						-- snippets plugin
	 {'rafamadriz/friendly-snippets'},			-- bunch of snippets

	-- latex support
	 {'lervag/vimtex'},

	-- thematic and visual packages
	 {'lunarvim/colorschemes'},					-- vimscript colorschemes
	 {'nvim-lualine/lualine.nvim',				-- fancier statusline
		dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true }
	 },
	-- specific colorschemes
	 {'EdenEast/nightfox.nvim'},
	 {'joshdick/onedark.vim'},
	 {'tjdevries/colorbuddy.nvim'},
	 {'tjdevries/gruvbuddy.nvim'},

}

require("lazy").setup(plugins, {
	-- automatically check for plugin updates
	checker = { 
		enabled = true,
		notify = false,
	},
})

