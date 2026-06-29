local lint = require("lint")

-- Configure linters by filetype
lint.linters_by_ft = {
	python = { "ruff" },
	tex = { "chktex" },
	lua = { "luacheck" },
	markdown = { "markdownlint" },
}

-- Configure chktex to shut up (don't treat its nonzero exit code as a failure)
lint.linters.chktex.ignore_exitcode = true

-- Run only the linters whose executable is actually installed. Without this guard a
-- missing tool (e.g. markdownlint) throws "ENOENT" on every BufEnter / tab switch.
local function lint_if_available()
	local names = lint.linters_by_ft[vim.bo.filetype] or {}
	local available = {}
	for _, name in ipairs(names) do
		local linter = lint.linters[name]
		local cmd = type(linter) == "table" and linter.cmd or nil
		cmd = type(cmd) == "function" and cmd() or cmd
		if cmd and vim.fn.executable(cmd) == 1 then
			table.insert(available, name)
		end
	end
	if #available > 0 then
		lint.try_lint(available)
	end
end

-- Auto-lint on read/write/insert-leave. (BufEnter is intentionally avoided: it fires
-- on every window/tab/buffer switch, which is what caused the constant error spam.)
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = lint_if_available,
})
