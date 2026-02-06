local M = {}

function M.get_visual_selection()
	local _, ls, cs = unpack(vim.fn.getpos("'<"))
	local _, le, ce = unpack(vim.fn.getpos("'>"))

	local lines = vim.fn.getline(ls, le)
	---@cast lines string[]

	if #lines == 0 then
		return ""
	end

	lines[1] = string.sub(lines[1], cs)
	lines[#lines] = string.sub(lines[#lines], 1, ce)

	return table.concat(lines, "\n")
end

return M
