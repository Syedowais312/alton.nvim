local M = {}

function M.setup(opts)
	opts = opts or {}
	require("alton.llm").setup(opts)
	require("alton.explain.auto").setup(opts)
	require("alton.explain.custom").setup(opts)
end
return M
