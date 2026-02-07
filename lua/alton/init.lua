local M = {}
local current_request = nil

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("v", "<F2>", function()
		-- cancel previous request
		if current_request then
			current_request.cancelled = true
		end

		-- open popup immediately
		local popup = require("alton.ui.popup")
		local buf, win = popup.open({ "Thinking..." })

		-- yank visual selection
		vim.api.nvim_feedkeys('"+y<Esc>', "x", false)

		vim.defer_fn(function()
			local sel = vim.fn.getreg("+")

			if sel == "" then
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				return
			end

			current_request = {
				cancelled = false,
				buf = buf,
				win = win,
				id = vim.loop.hrtime(),
			}

			-- Create a beginner-friendly line-by-line explanation prompt
			local prompt = string.format(
				[[
highlighted code:

%s

Explain the above code line by line for a programming beginner. Format each explanation like:

Line 1: [code] - [simple explanation]
Line 2: [code] - [simple explanation] 
Line 3: [code] - [simple explanation]

Rules:
- Explain every line individually
- Use simple, beginner-friendly language
- No "let me know" or conversational phrases
- Be direct and educational
- Assume the user has never coded before
-keep the explanaion minimal and valid]],
				sel
			)

			require("alton.llm.groq").run(prompt, function(lines)
				local request_id = current_request.id

				if current_request.cancelled or current_request.id ~= request_id then
					return
				end

				if not current_request.buf or not vim.api.nvim_buf_is_valid(current_request.buf) then
					return
				end

				vim.bo[current_request.buf].modifiable = true
				vim.api.nvim_buf_set_lines(current_request.buf, 0, -1, false, lines)
				vim.bo[current_request.buf].modifiable = false

				-- Update popup height based on actual content
				require("alton.ui.popup").update_height(current_request.buf, current_request.win)
			end)
		end, 1)
	end)
end

return M
