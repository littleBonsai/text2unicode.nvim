local text2unicode = {}

local opts
local to_unicode_map
local from_unicode_map

local function transform_text(text)
	vim.print("Transforming: ", text)
	return text
end

function text2unicode.convert_current_line()
	local old_text = vim.api.nvim_get_current_line()
	local new_text = transform_text(old_text)
	vim.api.nvim_set_current_line(new_text)
end

function text2unicode.setup(opts_arg)
	opts = opts_arg or {}
	opts.DEBUG = opts.DEBUG or false
	opts.leader = opts.leader or "🌠"
	if opts.DEBUG then
		vim.print("text2unicode: opts = ", opts)
	end

	-- when in insert mode press <C-v> and then your desired key, so you should
	-- see if it is already mapped, or use ":imap keycode" to check...
	vim.keymap.set("i", "<M-l>", function()
		text2unicode.convert_current_line()
	end, {
		desc = "text2unicode: Transform abbreviations in current line",
	})
end

return text2unicode
