local M = {}

local GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

local function get_api_key()
	return os.getenv("GEMINI_API_KEY")
end

function M.run(prompt, on_done)
	local api_key = get_api_key()
	if not api_key then
		vim.notify("GEMINI_API_KEY not set", vim.log.levels.ERROR)
		return
	end

	local body = vim.fn.json_encode({
		contents = {
			{
				role = "user",
				parts = {
					{ text = prompt },
				},
			},
		},
	})

	vim.fn.jobstart({
		"curl",
		"-sS",
		"-X",
		"POST",
		GEMINI_URL .. "?key=" .. api_key,
		"-H",
		"Content-Type: application/json",
		"-d",
		body,
	}, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if not data then
				return
			end

			local raw = table.concat(data, "")
			local ok, decoded = pcall(vim.fn.json_decode, raw)
			if not ok then
				vim.notify("Gemini response parse failed", vim.log.levels.ERROR)
				return
			end

			local text = decoded.candidates
				and decoded.candidates[1]
				and decoded.candidates[1].content
				and decoded.candidates[1].content.parts
				and decoded.candidates[1].content.parts[1]
				and decoded.candidates[1].content.parts[1].text

			if text then
				on_done(text)
			else
				vim.notify("Empty Gemini response", vim.log.levels.WARN)
			end
		end,
	})
end

return M
