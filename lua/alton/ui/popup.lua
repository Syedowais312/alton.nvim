local M = {}
function M.open(lines)
	-- Ensure lines is a table
	if type(lines) ~= "table" then
		lines = { tostring(lines) }
	end
	local buf = vim.api.nvim_create_buf(false, true)
	-- Use pcall to safely set lines
	local ok, err = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
	if not ok then
		vim.notify("Error setting buffer lines: " .. tostring(err), vim.log.levels.ERROR)
		return nil, nil
	end
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	-- Get current window width and use most of it
	local win_width = vim.api.nvim_win_get_width(0)
	local width = math.floor(win_width * 0.95) -- Use 95% of window width
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.3))

	-- Define custom highlight groups
	vim.api.nvim_set_hl(0, "MyFloatNormal", { bg = "#1e1e2e", fg = "#cdd6f4" })
	vim.api.nvim_set_hl(0, "MyFloatBorder", { bg = "#1e1e2e", fg = "#89b4fa" })
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	-- Set window-local highlights after creating the window
	vim.wo[win].winhighlight = "Normal:MyFloatNormal,FloatBorder:MyFloatBorder"
	vim.keymap.set("n", "q", function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, { buffer = buf, nowait = true, silent = true })
	return buf, win
end
function M.update_height(buf, win)
	if not buf or not win or not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, 0, -1, false)
	if not ok then
		return
	end
	local line_count = #lines

	-- Get current window width for dynamic sizing
	local win_width = vim.api.nvim_win_get_width(0)
	local new_width = math.floor(win_width * 0.95) -- Use 95% of window width
	local new_height = math.min(line_count + 1, math.floor(vim.o.lines * 0.6))

	pcall(vim.api.nvim_win_set_width, win, new_width)
	pcall(vim.api.nvim_win_set_height, win, new_height)
end
return M
