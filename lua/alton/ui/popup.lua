local M = {}

function M.open(lines)
	local buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "markdown"

	local width = math.min(80, vim.o.columns - 4)
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

return M
