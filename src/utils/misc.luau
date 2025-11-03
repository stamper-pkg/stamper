-- stamper misc utils
-- written by primiti-ve on github

local miscUtils = {}

local function escapePattern(str: string): string
	return str:gsub("(%W)", "%%%1")
end

function miscUtils.append(text: string, point: string, appended: string)
	local escapedPoint = escapePattern(point)

	local pattern1 = "^(.-)" .. escapedPoint .. "%s*(.-)\n%[.-%]\n(.*)$"
	local before, depsSection, after = text:match(pattern1)

	if not before then
		local pattern2 = "^(.-)" .. escapedPoint .. "%s*(.*)$"
        
		before, depsSection = text:match(pattern2)
		after = ""
	end

	depsSection = depsSection:gsub("^%s+", ""):gsub("%s+$", "")

	local newDepsSection

	if depsSection == "" then
		newDepsSection = appended
	else
		newDepsSection = depsSection .. "\n" .. appended
	end

	text = string.format("%s%s\n%s\n\n%s", before, point, newDepsSection, after)
	text = text:gsub("\n\n\n+", "\n\n")

	return text
end

return miscUtils
