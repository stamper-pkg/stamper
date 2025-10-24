local Compressor = {}

local HEADER = `LZW1`
local BASE = 95
local ASCII_OFFSET = 32
local MAX_CODE = 4095
local FIRST_CODE = 256

function Compressor.compress(input: string): string
	local dict = {}

	for i = 0, 255 do
		dict[string.char(i)] = i
	end

	local next_code = FIRST_CODE

	local w = ``
	local out_parts = {}

	for i = 1, #input do
		local c = string.sub(input, i, i)
		local wc = w .. c

		if dict[wc] ~= nil then
			w = wc
		else
			local code = dict[w]

			local a = math.floor(code / BASE)
			local b = code % BASE

			out_parts[#out_parts + 1] = string.char(a + ASCII_OFFSET, b + ASCII_OFFSET)

			if next_code <= MAX_CODE then
				dict[wc] = next_code
				next_code = next_code + 1
			end

			w = c
		end
	end

	if w ~= `` then
		local code = dict[w]
		local a = math.floor(code / BASE)
		local b = code % BASE

		out_parts[#out_parts + 1] = string.char(a + ASCII_OFFSET, b + ASCII_OFFSET)
	end

	return HEADER .. table.concat(out_parts)
end

function Compressor.decompress(input: string): string
	if string.sub(input, 1, #HEADER) ~= HEADER then
		return input
	end

	local payload = string.sub(input, #HEADER + 1)
	local codes = {}
	local p = 1

	while p <= #payload do
		if p + 1 > #payload then
			error(`Malformed compressed input (odd length)`)
		end

		local c1 = string.byte(payload, p) - ASCII_OFFSET
		local c2 = string.byte(payload, p + 1) - ASCII_OFFSET

		if not c1 or not c2 or c1 < 0 or c1 >= BASE or c2 < 0 or c2 >= BASE then
			error(`Malformed compressed input (invalid printable chars)`)
		end

		local code = c1 * BASE + c2

		codes[#codes + 1] = code
		p = p + 2
	end

	local dict = {}

	for i = 0, 255 do
		dict[i] = string.char(i)
	end

	local next_code = FIRST_CODE

	local result_parts = {}
	local prev = nil

	for idx = 1, #codes do
		local code = codes[idx]
		local entry = nil

		if dict[code] ~= nil then
			entry = dict[code]
		else
			if code == next_code and prev ~= nil then
				entry = prev .. string.sub(prev, 1, 1)
			else
				error(`Bad compressed code sequence`)
			end
		end

		result_parts[#result_parts + 1] = entry

		if prev ~= nil and next_code <= MAX_CODE then
			dict[next_code] = prev .. string.sub(entry, 1, 1)
			next_code = next_code + 1
		end

		prev = entry
	end

	return table.concat(result_parts)
end

return Compressor
