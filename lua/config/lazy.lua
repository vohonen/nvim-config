
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

local plugins = {

	-- quality of life packages
	 {'nvim-treesitter/nvim-treesitter'},			-- better syntax highlighting
	 {'nvim-treesitter/nvim-treesitter-textobjects'}, -- better visual highlighting
	 {'tpope/vim-commentary'}, 					-- better commenting
	 {'lukas-reineke/indent-blankline.nvim'},		-- indentation guides
	 {'ggandor/lightspeed.nvim'},					-- faster jumping around
	 {'windwp/nvim-autopairs'},					-- close pairs
	 {'tpope/vim-surround'},					-- surround text with smth
	 {'kyazdani42/nvim-web-devicons'},			-- nice icons
	 {'kyazdani42/nvim-tree.lua',				-- file explorer
		lazy = false, 	-- load when needed but prepare early
  		priority = 100, -- higher loading priority 
	 },				

	-- git packages
	 {'tpope/vim-fugitive'}, 						-- git commands with :G
	 {'mhinz/vim-signify'},						-- highlight changes
	 {'tpope/vim-rhubarb'},						-- access files in Github

	-- LSP packages
	 {'williamboman/mason.nvim',					-- interface for managing LSP
		build = ":MasonUpdate"},					
     {'williamboman/mason-lspconfig.nvim'},		-- wrapper between Mason and lspconfig
	 {'neovim/nvim-lspconfig'},					-- configs for LSP client
	-- linting
	 {
		'mfussenegger/nvim-lint',
		event = { 'BufReadPre', 'BufNewFile' },
	 },
	 {
		'stevearc/conform.nvim',
		event = { 'BufReadPre', 'BufNewFile' },
	 },

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

	-- markdown support 
	{
		'iamcco/markdown-preview.nvim',
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

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

