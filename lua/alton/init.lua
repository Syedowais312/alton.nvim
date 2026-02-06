local M = {}
local current_request = nil

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("v", "<F2>", function()
		-- Cancel previous request if exists
		if current_request then
			current_request.cancelled = true
		end

		-- Create popup immediately for visual feedback
		local buf, win = require("alton.ui.popup").open({ "Thinking..." })

		-- Yank selection and exit visual mode
		vim.api.nvim_feedkeys('"+y<Esc>', "x", false)

		-- Very short delay to complete the yank
		vim.defer_fn(function()
			local sel = vim.fn.getreg("+")

			if sel == "" then
				print("DEBUG: No selection found")
				-- Close popup if no selection
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				return
			end

			print("DEBUG: New request with selection:", sel:sub(1, 50) .. "...")

			-- Create new request object with unique ID
			current_request = {
				cancelled = false,
				buf = buf,
				win = win,
				id = vim.loop.hrtime(), -- Unique timestamp for this request
			}

			require("alton.llm.groq").run(sel, function(text)
				-- Store the request ID for this callback
				local request_id = current_request.id

				print("DEBUG: Response received for request ID:", request_id)
				print("DEBUG: Current request ID:", current_request.id)
				print("DEBUG: Request cancelled:", current_request.cancelled)

				-- Ignore if this request was cancelled
				if current_request.cancelled or current_request.id ~= request_id then
					print("DEBUG: Ignoring outdated response")
					return
				end

				print("DEBUG: Updating popup with response")
				vim.schedule(function()
					if not current_request.buf or not vim.api.nvim_buf_is_valid(current_request.buf) then
						return
					end

					vim.bo[current_request.buf].modifiable = true
					vim.api.nvim_buf_set_lines(current_request.buf, 0, -1, false, vim.split(text, "\n"))
					vim.bo[current_request.buf].modifiable = false
				end)
			end)
		end, 1) -- Minimal delay for yank operation
	end)
end

return M
