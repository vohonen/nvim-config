-- nvim-treesitter `main` branch (the rewrite). The old
-- `require("nvim-treesitter.configs").setup{}` API is gone; parsers are installed via
-- `.install()` and highlight/indent are enabled per-buffer in a FileType autocmd.
-- install new language parsers with :TSInstall, see :h nvim-treesitter

require("nvim-treesitter").install({
	"lua",
	"vim",
	"vimdoc",
	"latex",
	"python",
	"bibtex",
	"zathurarc",
	"matlab",
	"bash",
	"markdown",
	"markdown_inline",
})

-- enable treesitter highlighting + indentation for any buffer whose parser is installed
-- (pcall guards filetypes that have no parser, replacing the old highlight/indent enable=true)
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- textobjects (main branch): explicit setup + keymaps (replaces the old `textobjects.select` block)
require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
})

vim.keymap.set({ "x", "o" }, "af", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select around function" })
vim.keymap.set({ "x", "o" }, "if", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select inside function" })
