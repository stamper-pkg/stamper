-- table utils
-- written by primiti-ve on github

function sortFlags(flags: { string })
	table.sort(flags, function(a, b)
		local aCount = 0
		local bCount = 0

		for _, char in pairs(string.split(a, ``)) do 
			if char == `-` then 
				aCount += 1
			end
		end

		for _, char in pairs(string.split(b, ``)) do 
			if char == `-` then 
				bCount += 1
			end
		end

		return aCount > bCount
	end)
end

function getTableLength(tbl: { any })
	local index = 0

	for _, _ in pairs(tbl) do 
		index += 1
	end

	return index
end

return {
    sortFlags = sortFlags,
	getTableLength = getTableLength,
}