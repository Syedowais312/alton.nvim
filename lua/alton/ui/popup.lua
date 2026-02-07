local M = {}

function M.open(lines)
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	local width = math.min(120, vim.o.columns - 8)
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.3))

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, nowait = true, silent = true })

	return buf, win
end

-- New function to update popup size based on content
function M.update_height(buf, win)
	if not buf or not win or not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local line_count = #lines
	
	-- Calculate optimal width based on content
	local max_line_length = 0
	for _, line in ipairs(lines) do
		max_line_length = math.max(max_line_length, vim.fn.strdisplaywidth(line))
	end
	
	-- Update dimensions
	local new_width = math.min(math.max(max_line_length + 10, 80), math.min(150, vim.o.columns - 8))
	local new_height = math.min(line_count + 1, math.floor(vim.o.lines * 0.6))
	
	vim.api.nvim_win_set_width(win, new_width)
	vim.api.nvim_win_set_height(win, new_height)
end

return M
