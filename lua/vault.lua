-- Productivity vault integration (Obsidian-style plain-markdown vault).
-- Edited entirely from Neovim; Obsidian not used on this machine.
-- Vault lives on a plain local path, deliberately off Dropbox: macOS gates
-- ~/Library/CloudStorage behind Full Disk Access, which the terminal is not given.
-- Synced via git, not Dropbox. Change this one path if the vault ever moves.
local vault = vim.fn.expand("~/vault")

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

-- open/create the daily note `day_offset` days from today (0 = today, 1 = tomorrow)
local function open_daily(day_offset)
	local date = os.date("%Y-%m-%d", os.time() + day_offset * 86400)
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
end

-- <leader>td : open/create today's daily note from the template
vim.keymap.set("n", "<leader>td", function()
	open_daily(0)
end, { desc = "vault: open today's daily note" })

-- <leader>tm : open/create tomorrow's daily note (for EOD next-day planning)
vim.keymap.set("n", "<leader>tm", function()
	open_daily(1)
end, { desc = "vault: open tomorrow's daily note" })

-- End-of-day reminders stay active while Neovim is open.  Re-setting them
-- replaces the previous pair, which makes correcting a time painless.
local eod_timers = {}

local function clear_eod_timers()
	for _, timer in ipairs(eod_timers) do
		if not timer:is_closing() then
			timer:stop()
			timer:close()
		end
	end
	eod_timers = {}
end

local function macos_notification(message)
	vim.fn.jobstart({
		"osascript",
		"-e",
		('display notification "%s" with title "End of workday" sound name "Glass"'):format(message),
	})
end

local function set_eod_alarms(time)
	local hour, minute = time:match("^(%d%d):(%d%d)$")
	hour, minute = tonumber(hour), tonumber(minute)
	if not hour or not minute or hour > 23 or minute > 59 then
		notify("Use HH:MM (for example, 17:30)", vim.log.levels.ERROR)
		return
	end

	local now = os.time()
	local today = os.date("*t", now)
	local target = os.time({
		year = today.year,
		month = today.month,
		day = today.day,
		hour = hour,
		min = minute,
		sec = 0,
	})
	local seconds_until_stop = target - now
	if seconds_until_stop <= 30 * 60 then
		notify("Choose a stop time more than 30 minutes from now", vim.log.levels.ERROR)
		return
	end

	clear_eod_timers()
	for _, alarm in ipairs({
		{ delay = seconds_until_stop - 30 * 60, message = "30 minutes left — begin winding down and plan tomorrow." },
		{ delay = seconds_until_stop - 10 * 60, message = "10 minutes left — close tasks, move leftovers, and stop on time." },
	}) do
		local timer = vim.uv.new_timer()
		timer:start(alarm.delay * 1000, 0, vim.schedule_wrap(function()
			macos_notification(alarm.message)
			timer:close()
		end))
		table.insert(eod_timers, timer)
	end

	notify("End-of-day alarms set for " .. time)
end

vim.api.nvim_create_user_command("EndOfDay", function(opts)
	set_eod_alarms(opts.args)
end, { nargs = 1, desc = "Set 30- and 10-minute end-of-day alarms" })

-- <leader>te : prompt for a stop time and set end-of-day alarms
vim.keymap.set("n", "<leader>te", function()
	local time = vim.fn.input("End of workday (HH:MM)> ")
	if time ~= "" then
		set_eod_alarms(time)
	end
end, { desc = "vault: set end-of-day alarms" })

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
