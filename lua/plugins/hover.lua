local status_ok, hover = pcall(require, "hover")
if not status_ok then
	return
end

hover.setup({
	init = function()
		-- Required: LSP hover provider
		require("hover.providers.lsp")

		-- Optional: Uncomment to enable other providers
		-- require('hover.providers.gh')          -- GitHub issues/PRs
		-- require('hover.providers.gh_user')     -- GitHub user info
		-- require('hover.providers.jira')        -- Jira issues
		-- require('hover.providers.dap')         -- Debug Adapter Protocol
		-- require('hover.providers.man')         -- Man pages
		-- require('hover.providers.dictionary')  -- Dictionary definitions
	end,

	preview_opts = {
		border = "rounded",
	},

	-- Whether to use the floating window for preview
	preview_window = false,

	-- Show title in hover window
	title = true,

	-- Mouse support
	mouse_providers = {
		"LSP",
	},

	-- Delay before showing hover (ms)
	mouse_delay = 1000,
})

-- Keymaps
-- Hover documentation
vim.keymap.set("n", "gK", function()
	require("hover").hover()
end, { desc = "Hover Documentation" })
