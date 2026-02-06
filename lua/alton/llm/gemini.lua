local M = {}

local GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

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
		generationConfig = {
			maxOutputTokens = 1024,
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

			local function extract_text(decoded)
				if not decoded or not decoded.candidates then
					return nil
				end

				local parts = decoded.candidates[1].content.parts
				if not parts then
					return nil
				end

				local result = {}
				for _, part in ipairs(parts) do
					if part.text then
						table.insert(result, part.text)
					end
				end

				return table.concat(result, "")
			end
			local text = extract_text(decoded)

			if text and text ~= "" then
				on_done(text)
			else
				vim.notify("Empty Gemini response", vim.log.levels.WARN)
			end
		end,
	})
end

return M
