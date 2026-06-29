-- Required plugins:
-- - mason.nvim
-- - mason-lspconfig.nvim
-- - nvim-lspconfig
-- - nvim-cmp
-- - cmp-nvim-lsp
-- - cmp-buffer
-- - cmp-path
-- - LuaSnip
-- - cmp_luasnip

-- Initialize Mason
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- LSP completion capabilities (from nvim-cmp). Must be defined before servers are
-- configured so they can pick it up.
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- mason-lspconfig v2: the old `handlers` / `automatic_installation` options were removed.
-- Servers are auto-enabled (automatic_enable = true by default) via vim.lsp.enable(),
-- and shared config is applied with vim.lsp.config() instead of per-server handlers.
vim.lsp.config("*", { capabilities = capabilities })

require("mason-lspconfig").setup({
	-- LSP servers auto-installed via Mason. Add more as needed (see :Mason for names).
	ensure_installed = {
		"lua_ls", -- Lua (your Neovim config)
		"pyright", -- Python
		"marksman", -- Markdown
		"texlab", -- LaTeX
		"html", -- HTML
	},
})

-- Global keybindings for LSP
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })

-- Set up nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		-- Tab navigation for nvim-cmp
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})

-- Diagnostics only in the gutter
vim.diagnostic.config({
	virtual_text = false, -- Disable inline diagnostics
	signs = true, -- Show signs in the sign column
	underline = true, -- Underline the text with issues
	update_in_insert = false, -- Don't update diagnostics in insert mode
	severity_sort = true, -- Sort diagnostics by severity
	float = { -- Configure the floating window
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

vim.keymap.set("n", "<leader>td", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>ta", vim.diagnostic.setloclist)
