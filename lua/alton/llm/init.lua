local M = {}
local provider = nil

function M.setup(opts)
	opts = opts or {}
	local provider_name = opts.provider or "groq"

	if provider_name == "groq" then
		provider = require("alton.llm.providers.groq")
	elseif provider_name == "openai" then
		provider = require("alton.llm.providers.openai")
	elseif provider_name == "ollama" then
		provider = require("alton.llm.providers.ollama")
	elseif provider_name == "anthropic" then
		provider = require("alton.llm.providers.anthropic")
	else
		vim.notify("Unknown provider: " .. provider_name, vim.log.levels.ERROR)
		provider = require("alton.llm.providers.groq") -- fallback
	end

	provider.setup(opts[provider_name] or {})
end

function M.run(prompt, on_done)
	if not provider then
		vim.notify("LLM provider not initialized", vim.log.levels.ERROR)
		return
	end
	provider.run(prompt, on_done)
end

return M
