-- compression utils
-- written by primiti-ve on github

local Compressor = {}

function Compressor.compress(input: string): string
	local length = #input

	if length == 0 then
		return ""
	end

	local result = {}
	local count = 1
	local prev = input:sub(1, 1)

	for i = 2, length do
		local char = input:sub(i, i)

		if char == prev then
			count += 1
		else
			table.insert(result, prev .. tostring(count))

			prev = char
			count = 1
		end
	end
	
	table.insert(result, prev .. tostring(count))

	return table.concat(result)
end

function Compressor.decompress(input: string): string
	local result = {}
	local currentChar = nil
	local numBuffer = ""

	for i = 1, #input do
		local char = input:sub(i, i)

		if tonumber(char) then
			numBuffer ..= char
		else
			if currentChar and numBuffer ~= "" then
				local count = tonumber(numBuffer)

				table.insert(result, string.rep(currentChar, count :: number))

				numBuffer = ""
			end

			currentChar = char
		end
	end

	if currentChar and numBuffer ~= "" then
		local count = tonumber(numBuffer)

		table.insert(result, string.rep(currentChar, count :: number))
	end

	return table.concat(result)
end

return Compressor
