-- Productivity vault integration (Obsidian-style plain-markdown vault).
-- Edited entirely from Neovim; Obsidian not used on this machine.
-- Vault is Dropbox-synced. Change this one path if the vault ever moves.
local vault = vim.fn.expand("~/Dropbox/productivity-vault")

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "vault" })
end

-- <leader>ti : quick-capture a line into inbox.md (zero thinking about where it goes)
vim.keymap.set("n", "<leader>ti", function()
	local item = vim.fn.input("inbox> ")
	if item == "" then
		return
	end
	local path = vault .. "/inbox.md"
	local f = io.open(path, "a")
	if not f then
		notify("could not open " .. path, vim.log.levels.ERROR)
		return
	end
	f:write("- [ ] " .. item .. "\n")
	f:close()
	-- If inbox.md is open in a buffer, reload it so the new line shows immediately and
	-- a later :w from that buffer can't overwrite the line we just appended on disk.
	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
		vim.cmd("checktime " .. bufnr)
	end
	notify("→ inbox (saved)")
end, { desc = "vault: capture to inbox" })

-- <leader>td : open/create today's daily note from the template
vim.keymap.set("n", "<leader>td", function()
	local date = os.date("%Y-%m-%d")
	local path = vault .. "/daily/" .. date .. ".md"
	if vim.fn.filereadable(path) == 0 then
		local tmpl = io.open(vault .. "/templates/daily.md", "r")
		local body = tmpl and tmpl:read("*a") or ("# " .. date .. "\n")
		if tmpl then
			tmpl:close()
		end
		body = body:gsub("{{date:YYYY%-MM%-DD}}", date)
		local out = io.open(path, "w")
		if not out then
			notify("could not create " .. path, vim.log.levels.ERROR)
			return
		end
		out:write(body)
		out:close()
	end
	vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { desc = "vault: open today's daily note" })

-- <leader>to : open inbox.md directly (to process during a review)
vim.keymap.set("n", "<leader>to", function()
	vim.cmd("edit " .. vim.fn.fnameescape(vault .. "/inbox.md"))
end, { desc = "vault: open inbox" })

-- <leader>tv : cd into the vault and open the file tree
vim.keymap.set("n", "<leader>tv", function()
	if vim.fn.isdirectory(vault) == 0 then
		notify("vault not found at " .. vault, vim.log.levels.ERROR)
		return
	end
	vim.cmd("cd " .. vim.fn.fnameescape(vault))
	vim.cmd("NvimTreeOpen")
end, { desc = "vault: open vault tree" })
