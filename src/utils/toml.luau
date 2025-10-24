-- luau toml writer/reader
-- written by primiti-ve on github

local toml = {}

--// utility
local function trim(str: string): string
	return (string.match(str, `^%s*(.-)%s*$`))
end

local function parseInlineTable(value: string): { [string]: any }
	local tbl = {}

	value = value:match("^%{(.-)%}$" :: any)

	if not value then
		return tbl
	end

	for pair in value:gmatch(`[^,]+`) do
		local key, val = pair:match(`^(.-)=(.+)$`)

		if key and val then
			key = trim(key)
			val = trim(val)

			tbl[key] = (function(v)
				if v == `true` then
					return true
				elseif v == `false` then
					return false
				end

				local num = tonumber(v)

				if num then
					return num
				end

				local strValue = v:match('^`(.-)`$')

				if strValue then
					return strValue
				end

				return v
			end)(val)
		end
	end

	return tbl
end

local function parseValue(value: string): any
	value = trim(value)

	if value:match("^%b{}$") then
		return parseInlineTable(value)
	end

	if value == `true` then
		return true
	elseif value == `false` then
		return false
	end

	local num = tonumber(value)

	if num ~= nil then
		return num
	end

	local strValue = (value :: string):match('^`(.-)`$')

	if strValue then
		return strValue
	end

	return value
end

local function getOrCreateSection(root: {}, sectionPath: string)
	local current = root

	for part in sectionPath:gmatch(`[^%.]+`) do
		part = trim(part)

		current[part] = current[part] or {}
		current = current[part]
	end

	return current
end

--// toml reader
function toml.read(input: string): { [string]: any }
	local data = {}
	local currentSection = data

	for line in input:gmatch(`[^\r\n]+`) do
		line = trim(line)

		if line == `` or (line :: string):match(`^#`) then
			continue
		end

		local section = (line :: string):match(`^%[([^%]]+)%]$`)

		if section then
			currentSection = getOrCreateSection(data, section)
			continue
		end

		local key, value = (line :: string):match(`^(.-)=(.+)$`)

		if key and value then
			key = trim(key)
			value = parseValue(value)

			currentSection[key] = value
		end
	end

	return data
end

--// toml writer
local function serializeValue(value: any): string
	local t = typeof(value)

	if t == `boolean` then
		return value and `true` or `false`
	elseif t == `number` then
		return tostring(value)
	elseif t == `string` then
		local escaped = value:gsub('`', '\\`')

		return string.format('`%s`', escaped)
	elseif t == `table` then
		local parts = {}

		for k, v in pairs(value) do
			if typeof(v) ~= `table` then
				table.insert(parts, string.format(`%s = %s`, k :: string, serializeValue(v)))
			end
		end

		return string.format("{ %s }", table.concat(parts, `, `))
	else
		error(`Unsupported TOML value type: {t}`)
	end
end

local function isFlatTable(t: {}): boolean
	for _, v in pairs(t) do
		if typeof(v) == `table` then
			return false
		end
	end

	return true
end

function toml.write(tbl: { [string]: any }): string
	local lines = {}

	local function writeSection(sectionTable, sectionPath, isRoot)
		local primitives = {}
		local subtables = {}

		for key, value in pairs(sectionTable) do
			if typeof(value) == `table` then
				table.insert(subtables, key)
			else
				table.insert(primitives, { key, value })
			end
		end

		for _, pair in ipairs(primitives) do
			local key, value = pair[1], pair[2]
			table.insert(lines, string.format(`%s = %s`, key :: string, serializeValue(value)))
		end

		if #primitives > 0 and #subtables > 0 then
			table.insert(lines, ``)
		end

		for _, key in ipairs(subtables) do
			local sub = sectionTable[key]
			local newPath = sectionPath and (sectionPath .. `.` .. key) or key

			if next(sub) == nil then
				table.insert(lines, string.format(`[%s]`, newPath))
				table.insert(lines, ``)
			elseif isRoot then
				table.insert(lines, string.format(`[%s]`, key))

				writeSection(sub, key, false)

				table.insert(lines, ``)
			elseif isFlatTable(sub) then
				table.insert(lines, string.format(`%s = %s`, key, serializeValue(sub)))
			else
				table.insert(lines, string.format(`[%s]`, newPath))

				writeSection(sub, newPath, false)

				table.insert(lines, ``)
			end
		end
	end

	writeSection(tbl, nil, true)

	while lines[#lines] == `` do
		table.remove(lines)
	end

	return table.concat(lines, `\n`)
end

return toml
