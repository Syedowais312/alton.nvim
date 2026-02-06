local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("v", "<leader>tt", function()
		local sel = require("alton.selection").get_visual_selection()
		if sel == "" then
			return
		end

		local lines = vim.split(sel, "\n", { plain = true })
		local buf, win = require("alton.ui.popup").open({ "Thinking..." })

		require("alton.llm.gemini").run(sel, function(text)
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
			end)
		end)
	end)
end

return M
