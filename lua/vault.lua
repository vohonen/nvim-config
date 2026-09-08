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

-- open/create `path`, seeding it from `templates/<template>` the first time and
-- substituting {{placeholder}} values into it. Shared by the daily and weekly
-- notes; `fallback` is the body used if the template file is missing.
local function open_from_template(path, template, substitutions, fallback)
	if vim.fn.filereadable(path) == 0 then
		local tmpl = io.open(vault .. "/templates/" .. template, "r")
		local body = tmpl and tmpl:read("*a") or fallback
		if tmpl then
			tmpl:close()
		end
		for placeholder, value in pairs(substitutions) do
			-- escape % in the value; gsub reads it as a capture reference
			body = body:gsub(vim.pesc(placeholder), (value:gsub("%%", "%%%%")))
		end
		vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
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

-- path of the daily note `day_offset` days from today (0 = today, 1 = tomorrow)
local function daily_path(day_offset)
	-- noon, so a DST shift can never move the date
	local now = os.date("*t")
	local time = os.time({ year = now.year, month = now.month, day = now.day, hour = 12 }) + day_offset * 86400
	local date = os.date("%Y-%m-%d", time)
	return vault .. "/daily/" .. date .. ".md", date, time
end

-- the quarter a date falls in, e.g. "2026-Q3"
local function quarter_of(time)
	local t = os.date("*t", time)
	return string.format("%d-Q%d", t.year, math.ceil(t.month / 3))
end

-- The rocks from that quarter's goal file, stripped of their checkboxes: the
-- daily note lists them to be looked at, not ticked. Read fresh every time, so
-- a new quarter needs no template edit.
local function read_rocks(quarter)
	local path = vault .. "/goals/" .. quarter .. ".md"
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local rocks, section = {}, nil
	for _, line in ipairs(vim.fn.readfile(path)) do
		local heading = line:match("^##%s+(.+)$")
		if heading then
			section = heading
		elseif section and section:match("^Rocks") then
			local text = line:match("^%s*%d+%.%s*%[.%]%s*(.+)$") or line:match("^%s*%d+%.%s+(.+)$")
			if text and text:match("%S") then
				table.insert(rocks, ("%d. %s"):format(#rocks + 1, text))
			end
		end
	end
	return #rocks > 0 and table.concat(rocks, "\n") or nil
end

-- The focus areas the last weekly review set for this note's week.
--
-- A note for a day in week N reads week N-1's review, because that is where the
-- focus for week N was written. Friday included: the review written on Friday
-- morning of week N plans week N+1, so Friday's own note still belongs to the
-- focus set the week before. Which review it came from is named in the note, so
-- a skipped week is visible rather than silently stale.
local function read_week_focus(time)
	for weeks_back = 1, 3 do
		local week = os.date("%G-W%V", time - weeks_back * 7 * 86400)
		local path = vault .. "/weekly/" .. week .. ".md"
		if vim.fn.filereadable(path) == 1 then
			local focus, collecting = {}, false
			for _, line in ipairs(vim.fn.readfile(path)) do
				if line:match("focus areas") then
					collecting = true
				elseif collecting then
					local text = line:match("^%s+%-%s*(.+)$")
					if text and text:match("%S") then
						table.insert(focus, "- " .. text)
					elseif not line:match("^%s") and line:match("%S") then
						break
					end
				end
			end
			-- say it out loud when the newest review is not last week's, so a
			-- skipped Friday cannot pass its focus off as current
			local label = weeks_back == 1 and ("from [[%s]]"):format(week)
				or ("last review [[%s]], %d weeks ago"):format(week, weeks_back)
			if #focus > 0 then
				return ("This week (%s):\n%s"):format(label, table.concat(focus, "\n"))
			end
			return ("This week (%s, set none):\n-"):format(label)
		end
	end
	return "This week (no review in the last three weeks):\n-"
end

-- open/create the daily note `day_offset` days from today
local function open_daily(day_offset)
	local path, date, time = daily_path(day_offset)
	local quarter = quarter_of(time)
	open_from_template(path, "daily.md", {
		["{{date:YYYY-MM-DD}}"] = date,
		["{{quarter}}"] = quarter,
		["{{rocks}}"] = read_rocks(quarter) or ("_no rocks set in goals/" .. quarter .. ".md_"),
		["{{week-focus}}"] = read_week_focus(time),
	}, "# " .. date .. "\n")
end

-- open/create this week's review note, ISO week (e.g. 2026-W37) to match the
-- `review` zsh alias, which opens the same file.
local function open_weekly()
	local week = os.date("%G-W%V")
	open_from_template(
		vault .. "/weekly/" .. week .. ".md",
		"weekly.md",
		{ ["{{week}}"] = week },
		"# Weekly review " .. week .. "\n"
	)
end

-- <leader>td : open/create today's daily note from the template
vim.keymap.set("n", "<leader>td", function()
	open_daily(0)
end, { desc = "vault: open today's daily note" })

-- <leader>tm : open/create tomorrow's daily note (for EOD next-day planning)
vim.keymap.set("n", "<leader>tm", function()
	open_daily(1)
end, { desc = "vault: open tomorrow's daily note" })

-- <leader>tr : open/create this week's review note. Also a command, because the
-- `review` zsh alias needs one owner for the template substitution rather than
-- its own `cp`, which left {{week}} unexpanded in the title.
vim.api.nvim_create_user_command("VaultWeekly", open_weekly, { desc = "Open this week's review note" })
vim.keymap.set("n", "<leader>tr", open_weekly, { desc = "vault: open this week's review note" })

-- ---------------------------------------------------------------------------
-- Timers: the end-of-day sequence, a 30-minute Pomodoro, and ad-hoc countdowns.
--
-- All three raise the same large, stay-until-acknowledged panel
-- (scripts/timer-alert.js) rather than a corner notification, because a corner
-- notification is easy to ignore.
--
-- Everything worth tuning — how many end-of-day warnings there are, what each
-- says, how long a Pomodoro is, how big the day's budget is — lives in
-- ~/vault/nvim/timers.lua, which
-- <leader>tc creates (pre-filled with the defaults below) and opens. That file
-- is re-read whenever a timer is set, so a saved edit applies to the next timer
-- you start; no restart.
-- ---------------------------------------------------------------------------

local timer_config_path = vault .. "/nvim/timers.lua"
local alert_script = vim.fn.stdpath("config") .. "/scripts/timer-alert.js"

local timer_defaults = {
	eod = {
		emoji = "⏰",
		emoji_size = 58,
		heading = "End of workday",
		button = "I'm wrapping up",
		sound = "Glass",
		-- One panel per entry, fired `minutes_before` minutes before the stop
		-- time you type in. Text before " — " is rendered as the headline.
		alarms = {
			{ minutes_before = 30, message = "30 minutes left — close and move tasks, empty the inbox." },
			{ minutes_before = 10, message = "10 minutes left — stop and reflect." },
		},
	},
	pomodoro = {
		minutes = 30,
		emoji = "🍅",
		emoji_size = 58,
		heading = "Pomodoro ended",
		message = "Time for a break — stand up and look away from the screen.",
		button = "Break time",
		sound = "Glass",
	},
	-- Pomodoro budget for the day. `pomodoros` is a normal 8-hour day with no
	-- meetings; each meeting hour costs `per_meeting_hour`; `overhead` is the
	-- closing half hour — moving tasks and emptying the inbox, low bandwidth by
	-- design — which is not available for MITs.
	day = {
		pomodoros = 8,
		per_meeting_hour = 2,
		overhead = 1,
		minimum = 4,
	},
	timer = {
		emoji = "⏳",
		emoji_size = 58,
		heading = "Timer done",
		message = "{minutes} {unit} {is} up.",
		button = "Got it",
		sound = "Glass",
	},
}

local function load_timer_config()
	local config = vim.deepcopy(timer_defaults)
	if vim.fn.filereadable(timer_config_path) == 0 then
		return config
	end
	local chunk, load_error = loadfile(timer_config_path)
	if not chunk then
		notify("timers.lua: " .. load_error, vim.log.levels.ERROR)
		return config
	end
	local ok, user = pcall(chunk)
	if not ok or type(user) ~= "table" then
		notify("timers.lua must return a table — using defaults", vim.log.levels.ERROR)
		return config
	end
	-- A user-supplied alarm list replaces the default one outright: a deep merge
	-- would keep default entries hanging off the end of a shorter list.
	local alarms = user.eod and user.eod.alarms
	config = vim.tbl_deep_extend("force", config, user)
	if alarms then
		config.eod.alarms = alarms
	end
	return config
end

-- {minutes} is the timer length; {unit} and {is} agree with it, so a message
-- reads "1 minute is up" as well as "25 minutes are up".
local function fill(template, minutes)
	local singular = minutes == 1
	local text = (template or "")
		:gsub("{minutes}", tostring(minutes))
		:gsub("{unit}", singular and "minute" or "minutes")
		:gsub("{is}", singular and "is" or "are")
	return text
end

local function alert(spec)
	vim.fn.jobstart({ "osascript", "-l", "JavaScript", alert_script, vim.json.encode(spec) }, { detach = true })
end

-- Pending timers, kept so they can be replaced or cancelled. "eod" is a slot:
-- setting a stop time replaces the whole previous sequence, which makes fixing
-- a mistyped time painless. Pomodoros and ad-hoc timers accumulate.
local pending = { eod = {}, adhoc = {} }

local function cancel_timers(group)
	local count = 0
	for _, timer in ipairs(pending[group]) do
		if not timer:is_closing() then
			timer:stop()
			timer:close()
			count = count + 1
		end
	end
	pending[group] = {}
	return count
end

local function schedule(group, delay_seconds, spec, on_fire)
	local timer = vim.uv.new_timer()
	table.insert(pending[group], timer)
	timer:start(
		delay_seconds * 1000,
		0,
		vim.schedule_wrap(function()
			alert(spec)
			if on_fire then
				-- never let bookkeeping swallow the alert
				pcall(on_fire)
			end
			if not timer:is_closing() then
				timer:close()
			end
			for index, entry in ipairs(pending[group]) do
				if entry == timer then
					table.remove(pending[group], index)
					break
				end
			end
		end)
	)
end

local function ends_at(minutes)
	return os.date("%H:%M", os.time() + math.floor(minutes * 60))
end

local function set_eod_alarms(time)
	local hour, minute = time:match("^(%d?%d):(%d%d)$")
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
	if seconds_until_stop <= 0 then
		notify(time .. " has already passed today", vim.log.levels.ERROR)
		return
	end

	local config = load_timer_config().eod
	local alarms = vim.deepcopy(config.alarms)
	table.sort(alarms, function(a, b)
		return (a.minutes_before or 0) > (b.minutes_before or 0)
	end)

	cancel_timers("eod")
	local scheduled, missed = {}, {}
	for _, alarm in ipairs(alarms) do
		local delay = seconds_until_stop - (alarm.minutes_before or 0) * 60
		if delay > 0 then
			schedule("eod", delay, {
				emoji = config.emoji,
				emoji_size = config.emoji_size,
				heading = config.heading,
				message = alarm.message,
				button = config.button,
				sound = config.sound,
			})
			table.insert(scheduled, alarm.minutes_before)
		else
			table.insert(missed, alarm.minutes_before)
		end
	end

	if #scheduled == 0 then
		notify("Every end-of-day warning would already have fired before " .. time, vim.log.levels.WARN)
		return
	end
	local message = ("End of workday %s — notifications at %s min"):format(time, table.concat(scheduled, ", "))
	if #missed > 0 then
		message = message .. (" (%s min already passed)"):format(table.concat(missed, ", "))
	end
	notify(message)
end

local function start_timer(minutes)
	minutes = tonumber(minutes)
	if not minutes or minutes <= 0 then
		notify("Give a length in minutes (for example, 25)", vim.log.levels.ERROR)
		return
	end
	local config = load_timer_config().timer
	schedule("adhoc", minutes * 60, {
		emoji = config.emoji,
		emoji_size = config.emoji_size,
		heading = config.heading,
		message = fill(config.message, minutes),
		button = config.button,
		sound = config.sound,
	})
	notify(("Timer: %s min, ends %s"):format(minutes, ends_at(minutes)))
end

-- assigned in the day-budget section below; a finished Pomodoro records itself
local log_pomodoro

local function start_pomodoro()
	local config = load_timer_config().pomodoro
	local minutes = tonumber(config.minutes) or 30
	schedule("adhoc", minutes * 60, {
		emoji = config.emoji,
		emoji_size = config.emoji_size,
		heading = config.heading,
		message = fill(config.message, minutes),
		button = config.button,
		sound = config.sound,
	}, log_pomodoro)
	notify(("%s Pomodoro: %s min, ends %s"):format(config.emoji, minutes, ends_at(minutes)))
end

local function cancel_all_timers()
	local count = cancel_timers("eod") + cancel_timers("adhoc")
	notify(count == 0 and "No timers pending" or ("Cancelled %d timer(s)"):format(count))
end

-- Seed the vault config from the defaults above on first use, so there is a
-- populated file to edit instead of a blank one to guess at. vim.inspect emits
-- a valid Lua table literal, which keeps the defaults defined in exactly one
-- place.
local function open_timer_config()
	if vim.fn.filereadable(timer_config_path) == 0 then
		vim.fn.mkdir(vim.fn.fnamemodify(timer_config_path, ":h"), "p")
		local out = io.open(timer_config_path, "w")
		if not out then
			notify("could not create " .. timer_config_path, vim.log.levels.ERROR)
			return
		end
		out:write(table.concat({
			"-- Settings for the vault's daily flow: the timers (<leader>te, tt, tp) and",
			"-- the pomodoro budget the day is planned against (<leader>ts).",
			"-- Re-read every time a timer starts or a plan is checked: save, and the",
			"-- next one uses the new values. No restart.",
			"--",
			"-- Drop a key to fall back to its built-in default; delete the file to fall",
			'-- back to all of them. In a message, " — " splits headline from detail;',
			'-- {minutes} is the timer length, and {unit}/{is} agree with it ("1 minute',
			'-- is up", "25 minutes are up").',
			"return " .. vim.inspect(timer_defaults),
			"",
		}, "\n"))
		out:close()
	end
	vim.cmd("edit " .. vim.fn.fnameescape(timer_config_path))
end

vim.api.nvim_create_user_command("EndOfDay", function(opts)
	set_eod_alarms(opts.args)
end, { nargs = 1, desc = "Set the end-of-day warning sequence for a stop time (HH:MM)" })

vim.api.nvim_create_user_command("Timer", function(opts)
	start_timer(opts.args)
end, { nargs = 1, desc = "Start a timer for N minutes" })

vim.api.nvim_create_user_command("Pomodoro", start_pomodoro, { desc = "Start a Pomodoro" })

vim.api.nvim_create_user_command("TimersCancel", cancel_all_timers, { desc = "Cancel every pending timer" })

vim.api.nvim_create_user_command("VaultTimers", open_timer_config, { desc = "Edit vault timer settings" })

-- <leader>te : prompt for a stop time and set the end-of-day sequence
vim.keymap.set("n", "<leader>te", function()
	local time = vim.fn.input("End of workday (HH:MM)> ")
	if time ~= "" then
		set_eod_alarms(time)
	end
end, { desc = "vault: set end-of-day alarms" })

-- <leader>tt : prompt for a length in minutes and start a one-shot timer
vim.keymap.set("n", "<leader>tt", function()
	local minutes = vim.fn.input("Timer (minutes)> ")
	if minutes ~= "" then
		start_timer(minutes)
	end
end, { desc = "vault: start a timer for N minutes" })

-- <leader>tp : start a Pomodoro immediately (no prompt)
vim.keymap.set("n", "<leader>tp", start_pomodoro, { desc = "vault: start a Pomodoro" })

-- <leader>tx : cancel every pending timer
vim.keymap.set("n", "<leader>tx", cancel_all_timers, { desc = "vault: cancel pending timers" })

-- <leader>tc : open (creating on first use) the vault timer settings
vim.keymap.set("n", "<leader>tc", open_timer_config, { desc = "vault: edit timer settings" })

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

-- ---------------------------------------------------------------------------
-- Day budget: how much work today can actually hold.
--
-- The morning writes a capacity (pomodoros, minus meetings, minus the reserved
-- overhead block) and an estimate against each MIT; <leader>ts checks that the
-- estimates fit, and saving the daily note warns if they don't. That check is
-- the whole point: a plan you cannot exceed is not a plan.
--
-- A finished Pomodoro records itself in today's note, and <leader>tk rolls the
-- notes up into tracking/pomodoros.md. Those numbers are for calibrating next
-- week's estimates, never for grading the day.
-- ---------------------------------------------------------------------------

local tracking_path = vault .. "/tracking/pomodoros.md"

-- Read the numbers out of a daily note. Every field is optional: notes written
-- before the budget existed simply have nothing to report.
local function parse_daily_lines(lines)
	local out = { pomodoros = 0, mits_listed = 0, mits_done = 0 }
	local section
	for _, line in ipairs(lines) do
		local heading = line:match("^##%s+(.+)$")
		if heading then
			section = heading
		elseif section then
			if section:match("^Capacity") then
				local spent = line:match("^%s*[-*]?%s*[Pp]omodoros[^:]*:%s*(%d+)")
				if spent then
					out.pomodoros = tonumber(spent)
				end
				local meetings = line:match("^%s*[-*]?%s*[Mm]eetings[^:]*:%s*([%d%.]+)")
				if meetings then
					out.meetings = tonumber(meetings)
				end
			elseif section:match("^MITs") then
				local box, text = line:match("^%s*%d+%.%s*%[(.)%]%s*(.*)$")
				if box then
					out.mits_listed = out.mits_listed + 1
					if box:lower() == "x" then
						out.mits_done = out.mits_done + 1
					end
					local estimate = text:match("%((%d+)%s*p%)")
					if estimate then
						out.planned = (out.planned or 0) + tonumber(estimate)
					end
				end
			end
		end
	end
	return out
end

local function parse_daily(path)
	local lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {}
	return parse_daily_lines(lines)
end

-- capacity, reserved overhead, and what is left for MITs
local function day_budget(meetings)
	local day = load_timer_config().day
	local capacity = (tonumber(day.pomodoros) or 8) - (tonumber(day.per_meeting_hour) or 2) * (tonumber(meetings) or 0)
	capacity = math.max(capacity, tonumber(day.minimum) or 4)
	local overhead = tonumber(day.overhead) or 1
	return capacity, overhead, math.max(capacity - overhead, 0)
end

-- `quiet` reports only a plan that does not fit, for the on-save check
local function plan_status(quiet)
	local path = daily_path(0)
	if vim.fn.filereadable(path) == 0 then
		if not quiet then
			notify("no daily note for today yet — <leader>td", vim.log.levels.WARN)
		end
		return
	end
	local day = parse_daily(path)
	local capacity, overhead, mit_budget = day_budget(day.meetings)

	if day.mits_listed == 0 then
		-- headings are the parser's only anchor, so say so rather than
		-- reporting a confident zero
		if not quiet then
			notify("No MITs found — is the `## MITs` heading intact?", vim.log.levels.WARN)
		end
		return
	end

	if not day.planned then
		if not quiet then
			notify(
				("%d MITs, no (Np) estimates yet · budget %dp = %d capacity − %d overhead"):format(
					day.mits_listed,
					mit_budget,
					capacity,
					overhead
				),
				vim.log.levels.WARN
			)
		end
		return
	end

	local over = day.planned - mit_budget
	if over > 0 then
		notify(
			("Planned %dp across %d MITs — %dp over the %dp budget"):format(
				day.planned,
				day.mits_listed,
				over,
				mit_budget
			),
			vim.log.levels.WARN
		)
	elseif not quiet then
		notify(
			("Planned %dp / %dp · %d MITs · %d spent · %dp overhead reserved"):format(
				day.planned,
				mit_budget,
				day.mits_listed,
				day.pomodoros,
				overhead
			)
		)
	end
end

-- A finished Pomodoro bumps the count in today's note. If the note is open the
-- buffer is edited rather than the file, so an unsaved edit of yours is never
-- clobbered and you watch the count move. A note written before the Capacity
-- section existed gets one appended.
function log_pomodoro()
	local path = daily_path(0)
	if vim.fn.filereadable(path) == 0 then
		notify("Pomodoro not logged: no daily note for today", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.fn.bufnr(path)
	local in_buffer = bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr)
	local lines = in_buffer and vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) or vim.fn.readfile(path)

	local function put(index, count_lines, replacing)
		if in_buffer then
			vim.api.nvim_buf_set_lines(bufnr, index - 1, replacing and index or index - 1, false, count_lines)
		else
			if replacing then
				table.remove(lines, index)
			end
			for offset, line in ipairs(count_lines) do
				table.insert(lines, index + offset - 1, line)
			end
			vim.fn.writefile(lines, path)
		end
	end

	local count
	for index, line in ipairs(lines) do
		local prefix, value = line:match("^(%s*[-*]?%s*[Pp]omodoros[^:]*:%s*)(%d+)")
		if prefix then
			count = tonumber(value) + 1
			put(index, { prefix .. count }, true)
			break
		end
	end

	if not count then
		count = 1
		local heading
		for index, line in ipairs(lines) do
			if line:match("^##%s+Capacity") then
				heading = index
				break
			end
		end
		if heading then
			local at = #lines + 1
			for index = heading + 1, #lines do
				if lines[index]:match("^##%s") then
					at = index
					break
				end
			end
			while at - 1 > heading and lines[at - 1]:match("^%s*$") do
				at = at - 1
			end
			put(at, { "- Pomodoros: 1" }, false)
		else
			put(#lines + 1, { "", "## Capacity", "", "- Pomodoros: 1" }, false)
		end
	end

	local _, _, mit_budget = day_budget(parse_daily_lines(lines).meetings)
	notify(("🍅 %d / %dp%s"):format(count, mit_budget, in_buffer and " (unsaved)" or ""))
end

-- Roll the daily notes up into tracking/pomodoros.md. daily/ is deliberately
-- git-ignored, so this file is the durable record: rows are added or refreshed,
-- never dropped, and a day whose note is gone keeps its history.
local function update_tracking()
	local rows = {}
	if vim.fn.filereadable(tracking_path) == 1 then
		for _, line in ipairs(vim.fn.readfile(tracking_path)) do
			local date = line:match("^|%s*(%d%d%d%d%-%d%d%-%d%d)%s*|")
			if date then
				rows[date] = line
			end
		end
	end

	local added, refreshed = 0, 0
	for _, path in ipairs(vim.fn.glob(vault .. "/daily/*.md", false, true)) do
		local date = path:match("(%d%d%d%d%-%d%d%-%d%d)%.md$")
		if date then
			local day = parse_daily(path)
			local _, _, mit_budget = day_budget(day.meetings)
			local function shown(value)
				return value and tostring(value) or "–"
			end
			local line = ("| %s | %s | %s | %s | %s | %d/%d |"):format(
				date,
				shown(day.meetings),
				day.meetings and tostring(mit_budget) or "–",
				shown(day.planned),
				day.pomodoros > 0 and tostring(day.pomodoros) or "–",
				day.mits_done,
				day.mits_listed
			)
			if rows[date] == nil then
				added = added + 1
			elseif rows[date] ~= line then
				refreshed = refreshed + 1
			end
			rows[date] = line
		end
	end

	local dates = vim.tbl_keys(rows)
	table.sort(dates)
	local out = {
		"# Pomodoros & MITs",
		"",
		"Generated from `daily/*.md` by `:VaultTracking` (<leader>tk). Rows are only",
		"added or refreshed, never dropped — `daily/` is git-ignored, so this file is",
		"the record that survives a machine.",
		"",
		"`budget` is the MIT pomodoros left after the overhead block, `planned` sums",
		"the `(Np)` estimates, `spent` counts finished Pomodoros. For calibrating the",
		"next estimate, not for scoring the day.",
		"",
		"| date | mtg h | budget | planned | spent | MITs |",
		"|------|-------|--------|---------|-------|------|",
	}
	for _, date in ipairs(dates) do
		table.insert(out, rows[date])
	end

	vim.fn.mkdir(vim.fn.fnamemodify(tracking_path, ":h"), "p")
	vim.fn.writefile(out, tracking_path)
	notify(("tracking: %d days (%d new, %d refreshed)"):format(#dates, added, refreshed))
	vim.cmd("edit! " .. vim.fn.fnameescape(tracking_path))
end

vim.api.nvim_create_user_command("VaultPlan", function()
	plan_status(false)
end, { desc = "Check today's MIT estimates against the day budget" })

vim.api.nvim_create_user_command("VaultTracking", update_tracking, { desc = "Update the pomodoro/MIT record" })

-- <leader>ts : does today's plan fit the budget?
vim.keymap.set("n", "<leader>ts", function()
	plan_status(false)
end, { desc = "vault: check today's plan against the budget" })

-- <leader>tk : update and open tracking/pomodoros.md
vim.keymap.set("n", "<leader>tk", update_tracking, { desc = "vault: update pomodoro tracking" })

-- Saving the daily note warns when the plan does not fit, and stays quiet when
-- it does — so the check costs nothing on a day that is already reasonable.
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = vault .. "/daily/*.md",
	desc = "vault: warn when the day is planned over budget",
	callback = function()
		plan_status(true)
	end,
})
