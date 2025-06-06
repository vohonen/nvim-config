-- install new language parsers with :TSInstall, https://github.com/nvim-treesitter/nvim-treesitter#language-parsers
-- additional modules for syntax highlighting and indentation, https://github.com/nvim-treesitter/nvim-treesitter#available-modules
require('nvim-treesitter.configs').setup{
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"latex",
		"python",
		"bibtex",
		"zathurarc",
		"matlab",
		"bash"
	},
	highlight = {
		enable = true, -- false will disable the whole extension
	},
	indent = {
		enable = true,
	},
    textobjects = {
		select = {
		    enable = true,
		    lookahead = true,
		    keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
		    },
		},
    },
}

