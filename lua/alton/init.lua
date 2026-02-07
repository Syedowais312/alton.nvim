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

		if not buf or not win then
			vim.notify("Failed to create popup", vim.log.levels.ERROR)
			return
		end

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
Line 1: [code] 
- [elanation in detail of that line]
Line 2: [code]
- [explanation in detail of that line] 
Line 3: [code]
- [explanation in detail of that line]
Rules:
- Skip the lines if it has {},[], or similar thing whch are not neccessary
-skip the lines with comments
- Explain every line individually
- Use simple, beginner-friendly language
- No "let me know" or conversational phrases
- Be direct and educational
-skip explaining operators like =,==,:=,===/,*(basic syntax and operations)
- Assume the user has basic knowledge of coder(fimiliar with basiz syntax)
- Keep the explanation minimal and valid
-1 Line code 1(maximum 3-4lines only if the code has more new vairables and new function) Line explanation]],
				sel
			)

			require("alton.llm.groq").run(prompt, function(lines)
				-- Wrap in vim.schedule to ensure we're in the main event loop
				vim.schedule(function()
					-- Check if request was cancelled
					local request_id = current_request.id
					if current_request.cancelled or current_request.id ~= request_id then
						return
					end

					-- Validate buffer and window
					if not current_request.buf or not vim.api.nvim_buf_is_valid(current_request.buf) then
						return
					end

					if not current_request.win or not vim.api.nvim_win_is_valid(current_request.win) then
						return
					end

					-- Ensure lines is a valid table
					if type(lines) ~= "table" then
						lines = { tostring(lines) }
					end

					-- Update buffer with new content
					vim.bo[current_request.buf].modifiable = true
					local ok, err = pcall(vim.api.nvim_buf_set_lines, current_request.buf, 0, -1, false, lines)
					vim.bo[current_request.buf].modifiable = false

					if not ok then
						vim.notify("Error updating popup: " .. tostring(err), vim.log.levels.ERROR)
						return
					end

					-- Update popup height based on actual content
					require("alton.ui.popup").update_height(current_request.buf, current_request.win)
				end)
			end)
		end, 1)
	end)
end

return M
