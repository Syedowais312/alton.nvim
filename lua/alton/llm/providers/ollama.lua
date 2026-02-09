local M = {}
local config = {}

function M.setup(opts)
	config = vim.tbl_extend("force", {
		url = "http://localhost:11434/api/generate",
		model = "codellama",
	}, opts or {})
end

function M.run(prompt, on_done)
	local body = vim.fn.json_encode({
		model = config.model,
		prompt = prompt,
		stream = false,
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
		config.url,
		"-H",
		"Content-Type: application/json",
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
				safe_callback({ "Error: Invalid JSON" })
				return
			end

			if decoded.response then
				local lines = vim.split(decoded.response, "\n", { plain = true })
				safe_callback(lines)
			else
				safe_callback({ "Error: Empty response from Ollama" })
			end
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				safe_callback({ "Error: " .. table.concat(data, "") })
			end
		end,
		on_exit = function(_, code)
			if code ~= 0 and not callback_called then
				safe_callback({ "Error: Request failed (code " .. code .. ")" })
			end
		end,
	})
end

return M
