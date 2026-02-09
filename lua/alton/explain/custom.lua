local M = {}
local current_request = nil

function M.setup(opts)
	opts = opts or {}
	-- F3: New functionality with user input
	vim.keymap.set("v", "<F3>", function()
		-- Get current buffer
		local bufnr = vim.api.nvim_get_current_buf()

		-- Get visual selection range
		local start_pos = vim.fn.getpos("v")
		local end_pos = vim.fn.getpos(".")

		local start_line = start_pos[2] - 1
		local start_col = start_pos[3] - 1
		local end_line = end_pos[2] - 1
		local end_col = end_pos[3]

		-- Ensure start comes before end
		if start_line > end_line or (start_line == end_line and start_col > end_col) then
			start_line, end_line = end_line, start_line
			start_col, end_col = end_col, start_col
		end

		-- Get the selected text
		local selected_lines = vim.api.nvim_buf_get_text(bufnr, start_line, start_col, end_line, end_col, {})
		local selection = table.concat(selected_lines, "\n")

		-- Get total line count in buffer
		local total_lines = vim.api.nvim_buf_line_count(bufnr)

		-- Calculate context range (100 lines above and below)
		local context_start = math.max(0, start_line - 100)
		local context_end = math.min(total_lines - 1, end_line + 100)

		-- Get context lines
		local context_lines = vim.api.nvim_buf_get_lines(bufnr, context_start, context_end + 1, false)
		local context = table.concat(context_lines, "\n")

		-- Exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

		-- Check if selection is empty
		if selection == "" then
			vim.notify("No text selected", vim.log.levels.WARN)
			return
		end

		-- Get user input
		vim.ui.input({ prompt = "Enter your question about the code: " }, function(user_input)
			if not user_input or user_input == "" then
				vim.notify("No input provided", vim.log.levels.WARN)
				return
			end

			-- Cancel previous request
			if current_request then
				current_request.cancelled = true
			end

			-- Open popup after getting input
			local popup = require("alton.ui.popup")
			local buf, win = popup.open({ "Thinking..." })

			if not buf or not win then
				vim.notify("Failed to create popup", vim.log.levels.ERROR)
				return
			end

			current_request = {
				cancelled = false,
				buf = buf,
				win = win,
				id = vim.loop.hrtime(),
			}

			-- Create prompt with user input
			local prompt = string.format(
				[[
CONTEXT CODE (for reference only):
```
%s
```

SELECTED CODE:
```
%s
```

USER QUESTION: %s

Answer the user's question about the SELECTED CODE. Use the context code to understand references if needed.

Rules:
- Focus on answering the user's specific question
- Use simple, beginner-friendly language
- Be direct and educational
- Keep the explanation clear and concise]],
				context,
				selection,
				user_input
			)

			require("alton.llm").run(prompt, function(lines)
				vim.schedule(function()
					local request_id = current_request.id
					if current_request.cancelled or current_request.id ~= request_id then
						return
					end

					if not current_request.buf or not vim.api.nvim_buf_is_valid(current_request.buf) then
						return
					end

					if not current_request.win or not vim.api.nvim_win_is_valid(current_request.win) then
						return
					end

					if type(lines) ~= "table" then
						lines = { tostring(lines) }
					end

					vim.bo[current_request.buf].modifiable = true
					local ok, err = pcall(vim.api.nvim_buf_set_lines, current_request.buf, 0, -1, false, lines)
					vim.bo[current_request.buf].modifiable = false

					if not ok then
						vim.notify("Error updating popup: " .. tostring(err), vim.log.levels.ERROR)
						return
					end

					require("alton.ui.popup").update_height(current_request.buf, current_request.win)
				end)
			end)
		end)
	end)
end

return M
