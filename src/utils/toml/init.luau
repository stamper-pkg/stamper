-- luau toml writer/reader
-- written by primiti-ve on github

local toml = {}

--// toml reader
local function trim(str: string): string
	return (string.match(str, "^%s*(.-)%s*$"))
end

local function parseValue(value: string): any
	value = trim(value)

	if value == "true" then
		return true
	elseif value == "false" then
		return false
	end

	local num = tonumber(value)

	if num ~= nil then
		return num
	end

	local strValue = (value :: string):match('^"(.-)"$')

	if strValue then
		return strValue
	end

	return value
end

function toml.read(input: string): { [string]: any }
	local data = {}
	local currentSection: string? = nil

	for line in input:gmatch("[^\r\n]+") do
		line = trim(line)

		if line == "" or (line :: string):match("^#") then
			continue
		end

		local section = (line :: string):match("^%[([^%]]+)%]$")

		if section then
			currentSection = trim(section)

			if not data[currentSection] then
				data[currentSection] = {}
			end

			continue
		end

		local key, value = (line :: string):match("^(.-)=(.+)$")

		if key and value then
			key = trim(key)
			value = parseValue(value)

			if currentSection then
				data[currentSection][key] = value
			else
				data[key] = value
			end
		end
	end

	return data
end

--// toml writer
local function serializeValue(value: any): string
	local t = typeof(value)

	if t == "boolean" then
		return value and "true" or "false"
	elseif t == "number" then
		return tostring(value)
	elseif t == "string" then
		local escaped = value:gsub('"', '\\"')
        
		return string.format('"%s"', escaped)
	else
		error(`Unsupported TOML value type: {t}`)
	end
end

function toml.write(tbl: { [string]: any }): string
	local lines = {}

	for sectionName, sectionData in pairs(tbl) do
		if typeof(sectionData) == "table" then
			table.insert(lines, string.format("[%s]", sectionName))

			for key, value in pairs(sectionData) do
				local valStr = serializeValue(value)

				table.insert(lines, string.format("%s = %s", key :: string, valStr))
			end

			table.insert(lines, "")
		else
			local valStr = serializeValue(sectionData)

			table.insert(lines, string.format("%s = %s", sectionName, valStr))
		end
	end

	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	return table.concat(lines, "\n")
end

return toml
