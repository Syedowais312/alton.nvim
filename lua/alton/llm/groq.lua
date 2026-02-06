local M = {}

local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

local function get_api_key()
	-- Temporary hardcoded API key
	return os.getenv("GROQ_API_KEY") or "my_api_key-:---orewa-uffy"
end

function M.run(prompt, on_done)
	local api_key = get_api_key()
	if not api_key then
		vim.notify("GROQ_API_KEY not set", vim.log.levels.ERROR)
		return
	end

	local body = vim.fn.json_encode({
		model = "llama-3.1-8b-instant",
		messages = {
			{ role = "user", content = prompt },
		},
		temperature = 0.2,
	})

	local callback_called = false
	local function safe_callback(text)
		if not callback_called then
			callback_called = true
			vim.schedule(function()
				on_done(text)
			end)
		end
	end

	vim.fn.jobstart({
		"curl",
		"-sS",
		"-X",
		"POST",
		GROQ_URL,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"-d",
		body,
	}, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if not data or #data == 0 then
				return
			end

			local raw = table.concat(data, "")
			if raw == "" then
				return
			end

			local ok, decoded = pcall(vim.fn.json_decode, raw)
			if not ok then
				safe_callback("Error: Invalid JSON response - " .. raw)
				return
			end

			local text = decoded.choices
				and decoded.choices[1]
				and decoded.choices[1].message
				and decoded.choices[1].message.content

			if text then
				safe_callback(text)
			else
				safe_callback("Error: Empty response from Groq")
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				safe_callback("Error: " .. table.concat(data, ""))
			end
		end,
		on_exit = function(_, code)
			if code ~= 0 and not callback_called then
				safe_callback("Error: Request failed (code " .. code .. ")")
			end
		end,
	})
end

return M
