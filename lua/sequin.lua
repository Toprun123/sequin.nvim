local M = {}

local function format_table(data, columns_inp, window_width)
	local highlights = {}
	local function truncate(str, max_len)
		local max_screen_cutoff = math.floor(window_width * 0.75)
		str = tostring(str or "")
		if vim.fn.strdisplaywidth(str) > max_screen_cutoff then
			return str:sub(1, 20) .. "..."
		elseif vim.fn.strdisplaywidth(str) > max_len then
			if max_len <= 2 then
				return str:sub(1, max_len)
			else
				return str:sub(1, max_len - 2) .. ".."
			end
		end
		return str
	end
	local columns = {}
	for _, col in ipairs(columns_inp) do
		table.insert(columns, col.name)
	end
	local all_rows = {}
	table.insert(all_rows, columns)
	if #data == 0 then
		table.insert(all_rows, { "Empty table!" })
	end
	local function extract_first_nonempty_line(str)
		str = tostring(str or ""):gsub("\r", "")
		for line in str:gmatch("[^\n]*") do
			local trimmed = line:match("^%s*(.-)%s*$")
			if trimmed ~= "" then
				local suffix = #trimmed == #str and "" or "..."
				return trimmed .. suffix
			end
		end
		return ""
	end
	local function sanitize_blob(val)
		val = tostring(val or "")
		local output = {}
		local non_utf8_count = 0
		if val == "" then
			return vim.NIL
		end
		for i = 1, #val do
			local ch = val:sub(i, i)
			if vim.fn.strdisplaywidth(ch) == 1 then
				table.insert(output, ch)
			else
				non_utf8_count = non_utf8_count + 1
				table.insert(output, "�")
			end
		end
		if non_utf8_count >= 3 then
			return "BLOB"
		else
			return table.concat(output)
		end
	end
	for _, row in ipairs(data) do
		local new_row = {}
		for i, col in ipairs(columns) do
			local val = row[col]
			if columns_inp[i].type:upper():match("BOOL") then
				val = (val == "1" or val == 1) and "TRUE" or "FALSE"
			end
			if columns_inp[i].type:upper():match("BLOB") then
				val = sanitize_blob(val)
			end
			if type(val) == "string" then
				val = val:gsub("\r", "")
				val = extract_first_nonempty_line(val)
				if vim.fn.strdisplaywidth(val) > math.floor(window_width * 0.5) then
					val = val:sub(1, 20) .. "..."
				end
			end
			if val == nil or val == "" or val == vim.NIL or val == "vim.NIL" then
				val = "∅"
			end
			table.insert(new_row, tostring(val))
		end
		table.insert(all_rows, new_row)
	end
	local num_columns = #columns
	local col_widths = {}
	for i = 1, num_columns do
		col_widths[i] = 0
	end
	for _, row in ipairs(all_rows) do
		for i = 1, num_columns do
			local cell = row[i] or ""
			local width = vim.fn.strdisplaywidth(cell)
			if width > col_widths[i] then
				col_widths[i] = width
			end
		end
	end
	local total_content_width = 0
	for _, w in ipairs(col_widths) do
		total_content_width = total_content_width + w
	end
	local total_padding = 3 * num_columns + 1
	local remaining_space = window_width - total_padding - total_content_width
	while remaining_space > 0 do
		for i = 1, num_columns do
			col_widths[i] = col_widths[i] + 1
			remaining_space = remaining_space - 1
			if remaining_space <= 0 then
				break
			end
		end
	end
	local function draw_line(left, mid, right, hor)
		local parts = { left }
		for i = 1, num_columns do
			table.insert(parts, string.rep(hor, col_widths[i] + 2))
			if i < num_columns then
				table.insert(parts, mid)
			end
		end
		table.insert(parts, right)
		return table.concat(parts)
	end
	local imp_highlights = {}
	local top_border = draw_line("┌", "┬", "┐", "─")
	local mid_separator = draw_line("├", "┼", "┤", "─")
	local bottom_border = draw_line("└", "┴", "┘", "─")
	local formatted_lines = { top_border }
	table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" })
	for idx, row in ipairs(all_rows) do
		local row_parts = { "│" }
		table.insert(imp_highlights, {
			#formatted_lines,
			{ 0, 2 },
			"SequinBorder",
		})
		for i = 1, num_columns do
			local text = truncate(row[i] or "", col_widths[i])
			local function pad_display(str, width)
				local pad = width - vim.fn.strdisplaywidth(str)
				if pad > 0 then
					return str .. string.rep(" ", pad)
				else
					return str
				end
			end
			local padded = " " .. pad_display(text, col_widths[i]) .. " "
			local tmp_rp = table.concat(row_parts)
			if idx == 1 then
				local type = columns_inp[i].type:upper()
				local pk = columns_inp[i].pk == 1
				local hl_suffix
				if pk then
					table.insert(imp_highlights, {
						#formatted_lines,
						{ #tmp_rp + 1, #tmp_rp + col_widths[i] + 1 },
						"SequinPk",
					})
				else
					if type:match("INT") then
						hl_suffix = "Int"
					elseif type:match("CHAR") or type:match("TEXT") or type:match("CLOB") then
						hl_suffix = "String"
					elseif type:match("REAL") or type:match("FLOA") or type:match("DOUB") then
						hl_suffix = "Float"
					elseif type:match("BLOB") then
						hl_suffix = "Blob"
					elseif type:match("BOOL") then
						hl_suffix = "Bool"
					elseif type:match("DATE") or type:match("TIME") then
						hl_suffix = "Date"
					else
						hl_suffix = ""
					end
					table.insert(imp_highlights, {
						#formatted_lines,
						{ #tmp_rp + 1, #tmp_rp + #(truncate(row[i] or "", col_widths[i])) + 1 },
						"SequinTitles" .. hl_suffix,
					})
				end
			else
				if row[i] == "∅" then
					table.insert(imp_highlights, {
						#formatted_lines,
						{ #tmp_rp + 1, #tmp_rp + 4 },
						"SequinNull",
					})
				end
				if columns_inp[i].type:upper():match("BOOL") then
					if row[i] == "TRUE" then
						table.insert(imp_highlights, {
							#formatted_lines,
							{ #tmp_rp + 1, #tmp_rp + 5 },
							"SequinTrue",
						})
					elseif row[i] == "FALSE" then
						table.insert(imp_highlights, {
							#formatted_lines,
							{ #tmp_rp + 1, #tmp_rp + 6 },
							"SequinFalse",
						})
					end
				end
			end
			table.insert(row_parts, padded)
			table.insert(row_parts, "│")
			tmp_rp = table.concat(row_parts)
			table.insert(imp_highlights, {
				#formatted_lines,
				{ #tmp_rp - 3, #tmp_rp - 1 },
				"SequinBorder",
			})
		end
		table.insert(formatted_lines, table.concat(row_parts))
		if idx == 1 then
			table.insert(formatted_lines, mid_separator)
			table.insert(
				highlights,
				{ #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" }
			)
		else
			local hg = idx % 2 == 0 and "SequinRow" or "SequinRowAlt"
			table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, hg })
		end
	end
	table.insert(formatted_lines, bottom_border)
	table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" })
	for _, v in ipairs(imp_highlights) do
		table.insert(highlights, v)
	end
	return formatted_lines, highlights, col_widths
end

local function format_table_columnless(data, window_width)
	local highlights = {}
	local function truncate(str, max_len)
		local max_screen_cutoff = math.floor(window_width * 0.75)
		str = tostring(str or "")
		if vim.fn.strdisplaywidth(str) > max_screen_cutoff then
			return str:sub(1, 20) .. "..."
		elseif vim.fn.strdisplaywidth(str) > max_len then
			if max_len <= 2 then
				return str:sub(1, max_len)
			else
				return str:sub(1, max_len - 2) .. ".."
			end
		end
		return str
	end
	if #data == 0 then
		return { "Empty table!" }, {}, window_width
	end
	local columns = {}
	for col, _ in pairs(data[1]) do
		table.insert(columns, col)
	end
	table.sort(columns)
	local all_rows = {}
	table.insert(all_rows, columns)
	if #data == 0 then
		table.insert(all_rows, { "Empty table!" })
	end
	local function extract_first_nonempty_line(str)
		str = tostring(str or ""):gsub("\r", "")
		for line in str:gmatch("[^\n]*") do
			local trimmed = line:match("^%s*(.-)%s*$")
			if trimmed ~= "" then
				local suffix = #trimmed == #str and "" or "..."
				return trimmed .. suffix
			end
		end
		return ""
	end
	for _, row in ipairs(data) do
		local new_row = {}
		for _, col in ipairs(columns) do
			local val = row[col]
			if type(val) == "string" then
				val = val:gsub("\r", "")
				val = extract_first_nonempty_line(val)
				if vim.fn.strdisplaywidth(val) > math.floor(window_width * 0.5) then
					val = val:sub(1, 20) .. "..."
				end
			end
			if val == nil or val == "" or val == vim.NIL or val == "vim.NIL" then
				val = "∅"
			end
			table.insert(new_row, tostring(val))
		end
		table.insert(all_rows, new_row)
	end
	local num_columns = #columns
	local col_widths = {}
	for i = 1, num_columns do
		col_widths[i] = 0
	end
	for _, row in ipairs(all_rows) do
		for i = 1, num_columns do
			local cell = row[i] or ""
			local width = vim.fn.strdisplaywidth(cell)
			if width > col_widths[i] then
				col_widths[i] = width
			end
		end
	end
	local total_content_width = 0
	for _, w in ipairs(col_widths) do
		total_content_width = total_content_width + w
	end
	local total_padding = 3 * num_columns + 1
	local remaining_space = window_width - total_padding - total_content_width
	while remaining_space > 0 do
		for i = 1, num_columns do
			col_widths[i] = col_widths[i] + 1
			remaining_space = remaining_space - 1
			if remaining_space <= 0 then
				break
			end
		end
	end
	local function draw_line(left, mid, right, hor)
		local parts = { left }
		for i = 1, num_columns do
			table.insert(parts, string.rep(hor, col_widths[i] + 2))
			if i < num_columns then
				table.insert(parts, mid)
			end
		end
		table.insert(parts, right)
		return table.concat(parts)
	end
	local imp_highlights = {}
	local top_border = draw_line("┌", "┬", "┐", "─")
	local mid_separator = draw_line("├", "┼", "┤", "─")
	local bottom_border = draw_line("└", "┴", "┘", "─")
	local formatted_lines = { top_border }
	table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" })
	for idx, row in ipairs(all_rows) do
		local row_parts = { "│" }
		table.insert(imp_highlights, {
			#formatted_lines,
			{ 0, 2 },
			"SequinBorder",
		})
		for i = 1, num_columns do
			local text = truncate(row[i] or "", col_widths[i])
			local function pad_display(str, width)
				local pad = width - vim.fn.strdisplaywidth(str)
				if pad > 0 then
					return str .. string.rep(" ", pad)
				else
					return str
				end
			end
			local padded = " " .. pad_display(text, col_widths[i]) .. " "
			local tmp_rp = table.concat(row_parts)
			if idx == 1 then
				table.insert(imp_highlights, {
					#formatted_lines,
					{ #tmp_rp + 1, #tmp_rp + #(truncate(row[i] or "", col_widths[i])) + 1 },
					"SequinTitles",
				})
			else
				if row[i] == "∅" then
					table.insert(imp_highlights, {
						#formatted_lines,
						{ #tmp_rp + 1, #tmp_rp + 4 },
						"SequinNull",
					})
				end
			end
			table.insert(row_parts, padded)
			table.insert(row_parts, "│")
			tmp_rp = table.concat(row_parts)
			table.insert(imp_highlights, {
				#formatted_lines,
				{ #tmp_rp - 3, #tmp_rp - 1 },
				"SequinBorder",
			})
		end
		table.insert(formatted_lines, table.concat(row_parts))
		if idx == 1 then
			table.insert(formatted_lines, mid_separator)
			table.insert(
				highlights,
				{ #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" }
			)
		else
			local hg = idx % 2 == 0 and "SequinRow" or "SequinRowAlt"
			table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, hg })
		end
	end
	table.insert(formatted_lines, bottom_border)
	table.insert(highlights, { #formatted_lines - 1, { 0, #formatted_lines[#formatted_lines] - 1 }, "SequinBorder" })
	for _, v in ipairs(imp_highlights) do
		table.insert(highlights, v)
	end
	return formatted_lines, highlights, col_widths
end

local function get_usable_win_width(win_id)
	win_id = win_id or 0
	local total_width = vim.api.nvim_win_get_width(win_id)
	if total_width == 0 then
		return 0
	end
	local wo = vim.wo[win_id]
	local non_text_columns = 0
	if wo.number or wo.relativenumber then
		non_text_columns = non_text_columns + wo.numberwidth
	end
	if wo.signcolumn == "yes" then
		non_text_columns = non_text_columns + 2
	elseif wo.signcolumn == "auto" then
		non_text_columns = non_text_columns + 1
	elseif wo.signcolumn:match("%d+") then
		non_text_columns = non_text_columns + tonumber(wo.signcolumn)
	end
	non_text_columns = non_text_columns + wo.foldcolumn
	return total_width - non_text_columns - 2
end

local function set_mark(buf, ns_id, highlight)
	vim.api.nvim_buf_set_extmark(
		buf,
		ns_id,
		highlight[1] + 3,
		highlight[2][1],
		{ end_col = highlight[2][2], hl_group = highlight[3] }
	)
end

local function main_menu(buf)
	local tables =
		vim.fn.system("sqlite3 " .. vim.b[buf].db .. " 'SELECT name FROM sqlite_master WHERE type = \\'table\\';'")
	local tables_list = vim.split(tables, "\n", { trimempty = true })
	for i = 1, #tables_list do
		tables_list[i] = "   " .. tables_list[i]
	end
	table.insert(tables_list, 1, "   sqlite_master")
	table.insert(tables_list, 1, "")
	table.insert(tables_list, 1, "Sequin table menu for database: " .. vim.b[buf].db .. "")
	table.insert(tables_list, 1, "")
	vim.cmd("setlocal modifiable")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, tables_list)
	set_mark(
		buf,
		vim.b[buf].ns_id,
		{ -2, { 0, #("Sequin table menu for database: " .. vim.b[buf].db .. "") }, "SequinTitles" }
	)
	for i = 4, #tables_list do
		set_mark(buf, vim.b[buf].ns_id, { i - 4, { 0, #tables_list[i] }, "SequinTitlesFloat" })
	end
	vim.cmd("setlocal nomodifiable")
end

local function define_color(name, color_fg, color_bg, bold, underline, italic)
	if bold == nil then
		bold = true
	end
	if underline == nil then
		underline = false
	end
	if italic == nil then
		italic = false
	end
	vim.api.nvim_set_hl(0, name, { fg = color_fg, bg = color_bg, bold = bold, underline = underline, italic = italic })
end

local function get_table_data(db, table_name, limit, p_no)
	local query = string.format(
		[[
      bash -c 'sqlite3 %s -json <<EOF
        PRAGMA table_info(%s);
        SELECT \'delioneone\';
        SELECT * FROM %s limit %s offset %s;
        SELECT \'delitwotwo\';
        SELECT count(*) FROM %s;
EOF'
  ]],
		db,
		table_name,
		table_name,
		limit,
		p_no * limit,
		table_name
	)
	local result = vim.fn.system(query)
	local parts = {}
	local first_delim = '[{"\'delioneone\'":"delioneone"}]'
	local second_delim = '[{"\'delitwotwo\'":"delitwotwo"}]'
	local split_res = vim.split(result, "\n", { trimempty = true })
	local before = {}
	local middle = {}
	local after_second = {}
	local state = 0
	for _, line in ipairs(split_res) do
		if state == 0 then
			if line == first_delim then
				state = 1
			else
				table.insert(before, line)
			end
		elseif state == 1 then
			if line == second_delim then
				state = 2
			else
				table.insert(middle, line)
			end
		else
			table.insert(after_second, line)
		end
	end
	table.insert(parts, table.concat(before, "\n"))
	table.insert(parts, table.concat(middle, "\n"))
	table.insert(parts, table.concat(after_second, "\n"))
	local column_result = parts[1]
	column_result = column_result == "" and "{}" or column_result
	local ok_, columns = pcall(vim.fn.json_decode, column_result)
	if not ok_ then
		error("JSON decode failed: " .. tostring(columns))
	end
	parts[2] = parts[2] == "" and "{}" or parts[2]
	local ok, data = pcall(vim.fn.json_decode, parts[2])
	if not ok then
		error("JSON decode failed: " .. tostring(data))
	end
	parts[3] = parts[3] == "" and "{}" or parts[3]
	local ok__, count = pcall(vim.fn.json_decode, parts[3])
	if not ok__ then
		error("JSON decode failed: " .. tostring(count))
	end
	return data, columns, tonumber(count[1]["count(*)"])
end

local function table_data(buf, p_no)
	local f_table, columns, num = get_table_data(vim.b[buf].db, vim.b[buf].table_name, 20, p_no)
	local formatted, highlights, col_widths = format_table(f_table, columns, get_usable_win_width(0))
	table.insert(formatted, 1, "")
	local title = " Table: "
		.. vim.b[buf].table_name
		.. " (page "
		.. p_no + 1
		.. "/"
		.. (math.floor(num / 20) + 1)
		.. ") (of total "
		.. num
		.. " entries)"
	table.insert(formatted, 1, title)
	table.insert(formatted, 1, "")
	vim.cmd("setlocal modifiable")
	vim.api.nvim_buf_clear_namespace(buf, vim.b[buf].ns_id, 0, -1)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
	set_mark(buf, vim.b[buf].ns_id, { -2, { 0, #title }, "SequinTitles" })
	vim.cmd("setlocal nomodifiable")
	for _, highlight in ipairs(highlights or {}) do
		set_mark(buf, vim.b[buf].ns_id, highlight)
	end
	return num, col_widths
end

local function refresh(buf)
	if vim.b[buf].sqlite_setup_done then
		if vim.b[buf].state == "main" then
			main_menu(buf)
		else
			local p_no = vim.b[buf].p_no
			vim.b[buf].max, vim.b[buf].col_widths = table_data(buf, p_no)
		end
	end
end

local function find_column_at(pos, widths)
	local gap = 5
	local total = 2
	for i, width in ipairs(widths) do
		total = total + width + gap
		if total > pos then
			return i
		end
	end
	return -1
end

local function popup_data(buf, pos)
	if pos[1] - 7 < 0 or pos[1] - 7 >= vim.b[buf].max - 20 * vim.b[buf].p_no or pos[1] - 7 >= 20 then
		return
	end
	local data, cols, _ = get_table_data(vim.b[buf].db, vim.b[buf].table_name, 1, 20 * vim.b[buf].p_no + pos[1] - 7)
	local col_widths = vim.b[buf].col_widths
	local idx = find_column_at(pos[2], col_widths)
	if idx == -1 then
		return
	end
	local raw_value = data[1][cols[idx].name]
	if raw_value == vim.NIL then
		raw_value = "nil"
	end
	local str = raw_value and tostring(raw_value) or "nil"
	str = str:gsub("\r", "")
	local lines = vim.split(str, "\n", { plain = true })
	local width = 0
	for _, line in ipairs(lines) do
		if #line > width then
			width = #line
		end
	end
	width = math.max(10, math.min(width + 4, math.ceil(vim.o.columns * 0.75)))
	local height = math.max(10, math.min(#lines, math.ceil(vim.o.lines * 0.75)))
	local row = math.floor((vim.o.lines - height) / 2 - 1)
	local col = math.floor((vim.o.columns - width) / 2)
	local popup_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)
	local popup_win = vim.api.nvim_open_win(popup_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})
	vim.api.nvim_set_option_value("filetype", "text", { buf = popup_buf })
	vim.api.nvim_set_option_value("wrap", true, { win = popup_win })
	vim.api.nvim_set_option_value("linebreak", true, { win = popup_win })
	vim.keymap.set("n", "<Esc>", function()
		if vim.api.nvim_win_is_valid(popup_win) then
			vim.api.nvim_win_close(popup_win, true)
		end
	end, { buffer = popup_buf, nowait = true, noremap = true, silent = true })
end

local function run_exec(buf, query)
	local raw_value = vim.fn.system(string.format(
		[[
      bash -c 'sqlite3 %s <<EOF
        %s
EOF'
  ]],
		vim.b[buf].db,
		query
	))
	local str = raw_value and tostring(raw_value) or "nil"
	str = str:gsub("\r", "")
	local formatted = {}
	table.insert(formatted, "")
	table.insert(formatted, "Results of the query: " .. query)
	table.insert(formatted, "----------------------" .. string.rep("-", #query))
	table.insert(formatted, "")
	if str:match("^%s*$") then
		table.insert(formatted, "(No results returned.)")
	else
		for line in str:gmatch("[^\n]+") do
			table.insert(formatted, line)
		end
	end
	vim.cmd("setlocal modifiable")
	vim.api.nvim_buf_clear_namespace(buf, vim.b[buf].ns_id, 0, -1)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
	set_mark(buf, vim.b[buf].ns_id, { -2, { 0, #("Results of the query: " .. query) }, "SequinTitles" })
	for lnum = 4, #formatted - 1 do
		local line = formatted[lnum + 1] or ""
		local line_len = vim.fn.strdisplaywidth(line)
		vim.api.nvim_buf_set_extmark(buf, vim.b[buf].ns_id, lnum, 0, {
			end_line = lnum,
			end_col = line_len,
			hl_group = "SequinTitlesFloat",
		})
	end
	vim.cmd("setlocal nomodifiable")
end

local function run_select(buf, ns_id, query)
	local raw_value = vim.fn.system(string.format(
		[[
      bash -c 'sqlite3 %s -json <<EOF
        select %s
EOF'
  ]],
		vim.b[buf].db,
		query:gsub("'", "\\'")
	))
	local str = raw_value and tostring(raw_value) or "nil"
	str = str:gsub("\r", "")
	local ok, data = pcall(vim.fn.json_decode, str)
	if not ok then
		print(data)
		return
	end
	local num = #data
	local p_no = vim.b[buf].p_no
	local function paginate(tbl, page_size, page_number)
		local start_idx = (page_number - 1) * page_size + 1
		local end_idx = math.min(start_idx + page_size - 1, #tbl)
		local result = {}
		for i = start_idx, end_idx do
			table.insert(result, tbl[i])
		end
		return result
	end
	data = paginate(data, 20, p_no + 1)
	local formatted, highlights, col_widths = format_table_columnless(data, get_usable_win_width(0))
	table.insert(formatted, 1, "")
	table.insert(formatted, 1, "Results of the query: select " .. query)
	table.insert(formatted, 1, "")
	vim.cmd("setlocal modifiable")
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
	set_mark(buf, vim.b[buf].ns_id, { -2, { 0, #("Results of the query: select " .. query) }, "SequinTitles" })
	vim.cmd("setlocal nomodifiable")
	for _, highlight in ipairs(highlights or {}) do
		set_mark(buf, ns_id, highlight)
	end
	return num, col_widths
end

M.setup = function(_)
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = "*.db,*.sqlite,*.sqlite3",
		callback = function(args)
			local buf = args.buf
			if vim.b[buf].sqlite_setup_done then
				return
			end
			vim.b[buf].sqlite_setup_done = true
			vim.b[buf].ns_id = vim.api.nvim_create_namespace("sequin")
			vim.b[buf].db = vim.fn.expand("%")
			vim.b[buf].state = "main"
			vim.cmd("setlocal buftype=nofile")
			vim.cmd("setlocal nonumber")
			vim.cmd("setlocal norelativenumber")
			vim.cmd("setlocal nomodifiable")
			vim.cmd("setlocal nowrap")
			vim.cmd("setlocal nolist")
			define_color("SequinBorder", "#777777", nil, false, false, false)
			define_color("SequinRow", "#e5e5ff", nil, false, false, false)
			define_color("SequinRowAlt", "#ffe2e2", nil, false, false, false)
			define_color("SequinTitles", "#b0e57c", nil, false, false, false)
			define_color("SequinNull", "#ff4f78", nil, true, false, false)
			define_color("SequinPk", "#0a0b11", "#c5a3ff", true, false, false)
			define_color("SequinTitlesInt", "#8cdcff", nil, true, false, false)
			define_color("SequinTitlesString", "#f5f9af", nil, true, false, false)
			define_color("SequinTitlesFloat", "#89b4fa", nil, true, false, false)
			define_color("SequinTitlesBlob", "#ff99c2", nil, true, false, false)
			define_color("SequinTitlesBool", "#b0e57c", nil, true, false, false)
			define_color("SequinTitlesDate", "#ff9e64", nil, true, false, false)
			define_color("SequinFalse", "#ff4f78", nil, false, false, false)
			define_color("SequinTrue", "#b0e57c", nil, false, false, false)
			main_menu(buf)
			vim.keymap.set("n", "<CR>", function()
				if vim.b[buf].state == "main" then
					local table_name = string.sub(vim.fn.getline("."), 4)
					vim.b[buf].table_name = table_name
					vim.b[buf].max, vim.b[buf].col_widths = table_data(buf, 0)
					vim.b[buf].state = "table"
					vim.b[buf].p_no = 0
				elseif vim.b[buf].state == "table" then
					local pos = vim.api.nvim_win_get_cursor(0)
					popup_data(buf, pos)
				end
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "n", function()
				if vim.b[buf].state == "table" then
					local p_no = vim.b[buf].p_no + 1
					local max = vim.b[buf].max
					if p_no > (max / 20) then
						p_no = math.floor(max / 20)
					end
					vim.b[buf].max, vim.b[buf].col_widths = table_data(buf, p_no)
					vim.b[buf].p_no = p_no
				elseif vim.b[buf].state == "select-table" then
					local p_no = vim.b[buf].p_no + 1
					local max = vim.b[buf].max
					if p_no > (max / 20) then
						p_no = math.floor(max / 20)
					end
					vim.b[buf].p_no = p_no
					vim.b[buf].max, vim.b[buf].col_widths = run_select(buf, vim.b[buf].ns_id, vim.b[buf].query)
				end
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "N", function()
				if vim.b[buf].state == "table" then
					local p_no = vim.b[buf].p_no - 1
					if p_no < 0 then
						p_no = 0
					end
					vim.b[buf].max, vim.b[buf].col_widths = table_data(buf, p_no)
					vim.b[buf].p_no = p_no
				elseif vim.b[buf].state == "select-table" then
					local p_no = vim.b[buf].p_no - 1
					if p_no < 0 then
						p_no = 0
					end
					vim.b[buf].p_no = p_no
					vim.b[buf].max, vim.b[buf].col_widths = run_select(buf, vim.b[buf].ns_id, vim.b[buf].query)
				end
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "<Esc>", function()
				main_menu(buf)
				vim.b[buf].state = "main"
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "<Backspace>", function()
				main_menu(buf)
				vim.b[buf].state = "main"
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "r", function()
				refresh(buf)
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "x", function()
				vim.b[buf].state = "rand-query"
				local query = vim.fn.input("Query: ")
				if query == "" then
					return
				end
				run_exec(buf, query)
			end, { buffer = buf, noremap = true, silent = true })
			vim.keymap.set("n", "g", function()
				vim.b[buf].state = "select-table"
				local query = vim.fn.input("Query: select ")
				if query == "" then
					return
				end
				vim.b[buf].p_no = 0
				vim.b[buf].query = query
				vim.b[buf].max, vim.b[buf].col_widths = run_select(buf, vim.b[buf].ns_id, query)
			end, { buffer = buf, noremap = true, silent = true })
			vim.b.no_git_diff = true
		end,
	})
	vim.api.nvim_create_autocmd("VimResized", {
		pattern = "*.db,*.sqlite,*.sqlite3",
		callback = function(args)
			local buf = args.buf
			refresh(buf)
		end,
	})
end

return M
