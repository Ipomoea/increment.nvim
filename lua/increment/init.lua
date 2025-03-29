-- increment.nvim
-- Licensed under the MIT License: https://opensource.org/licenses/MIT

-- Config

local default_opts = {
	groups = {
		{ "+", "-" },
		{ "==", "!=" },
		{ "true", "false" },
		{ "YES", "NO" },
		{ "&&", "||" },
	},
	lang_groups = {
		lua = {
			{ "==", "~=" },
		},
		swift = {
			{ "let", "var" },
		},
	},
}

local M = {}

-- Utility

local error = function(msg)
	error("(increment) " .. msg, 0)
end

local check_type = function(name, val, ref)
	if type(val) == ref or (ref == "callable" and vim.is_callable(val)) or val == nil then
		return
	end
	error(string.format("`%s` should be %s, not %s", name, ref, type(val)))
end

local table_len = function(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local ft = function()
	return vim.api.nvim_buf_get_option(0, "filetype")
end

local fallback_key = function(key)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
end

-- Plugin

local get_cursor_word_in_groups = function(priority_groups, groups)
	local candidate = vim.fn.expand("<cword>")

	local find_in_groups = function(groups)
		for _, group in ipairs(groups) do
			for token_index, token in ipairs(group) do
				if candidate == token then
					return {
						group = group,
						token_index = token_index,
						length = #token,
					}
				end
			end
		end

		return nil
	end

	local result = (priority_groups and find_in_groups(priority_groups)) or find_in_groups(groups)

	if not result then
		return nil
	end

	local line = vim.fn.getline(".")
	local col = vim.fn.col(".")

	local start_col = nil
	local search_pos = 1

	while true do
		local found_col = line:find(candidate, search_pos, true)

		if not found_col then
			break
		end

		if found_col <= col and col < (found_col + #candidate) then
			start_col = found_col
			break
		end

		search_pos = found_col + 1
	end

	result.column = start_col

	return result
end

local replace_word = function(start_col, length, new_word)
	start_col = start_col - 1
	local line_num = vim.fn.line(".") - 1
	local end_col = start_col + length

	vim.api.nvim_buf_set_text(0, line_num, start_col, line_num, end_col, { new_word })
end

M.setup = function(opts)
	-- Export module
	_G.increment = M

	check_type("opts", opts, "table")
	M.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	-- Make `setup()` to proper reset module
	for _, m in ipairs(vim.fn.getmatches()) do
		if vim.startswith(m.group, "increment") then
			vim.fn.matchdelete(m.id)
		end
	end

	-- Setup keys
	vim.keymap.set("n", "<c-a>", M.increment, {})
	vim.keymap.set("n", "<c-x>", M.decrement, {})
end

M.increment = function()
	local match = get_cursor_word_in_groups(M.opts.lang_groups[ft()], M.opts.groups)
	if match then
		local group = match.group
		replace_word(match.column, match.length, group[match.token_index % table_len(group) + 1])
	else
		fallback_key("<c-a>")
	end
end

M.decrement = function()
	local match = get_cursor_word_in_groups(M.opts.lang_groups[ft()], M.opts.groups)
	if match then
		local group = match.group
		replace_word(match.column, match.length, group[(match.token_index - 2) % table_len(group) + 1])
	else
		fallback_key("<c-x>")
	end
end

return M
