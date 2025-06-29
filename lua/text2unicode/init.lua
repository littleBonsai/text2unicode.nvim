local text2unicode = {}

local opts
local to_unicode_map = {}
local from_unicode_map = {}

local function load_transformation_table()
	local lua_script_file = string.sub(debug.getinfo(1, "S").source, 2)
	local lua_script_directory = vim.fs.dirname(lua_script_file)
	local normalized_directory = vim.fs.normalize(lua_script_directory)
	local abbreviation_data_file = vim.fs.joinpath(
		normalized_directory,
		"../../abbreviation_data/abbreviations.json"
	)

	local file = io.open(abbreviation_data_file, "r")
	if not file then
		error(string.format("Unable to open file: %q", abbreviation_data_file))
	end

	local raw_table = vim.json.decode(file:read("*a"))
	file:close()

	for key, value in pairs(raw_table) do
		local first_char = key:sub(1, 1)
		local remaining_key = key:sub(2)

		-- 1st map: to unicode
		to_unicode_map[first_char] = to_unicode_map[first_char] or {}
		to_unicode_map[first_char][remaining_key] = value

		-- 2nd map: from unicode
		from_unicode_map[value] = from_unicode_map[value] or {}
		table.insert(from_unicode_map[value], key)
	end

	-- vim.print(vim.inspect(from_unicode_map))
	-- nvim: use "ga" in normal mode to get info about the character under
	--     the cursor
end

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

	load_transformation_table()
end

return text2unicode
