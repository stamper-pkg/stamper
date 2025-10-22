-- cli flag constructor
-- written by primiti-ve on github

export type flag = {
	_name: string,
	options: { [string]: string },
}

return function(internalName: string, names: string | { string }?, description: string?): flag
	local flag = {}

	flag._name = internalName
	flag.options = {}

	if type(names) == "string" then
		names = { names }
	end

	for _, name in pairs(names) do
		flag.options[name] = description
	end

	return flag
end
