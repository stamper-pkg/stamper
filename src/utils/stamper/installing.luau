-- installing utils
-- written by primiti-ve on github

local serde = require("@lune/serde")
local packageUtils = require("./package")

export type installData = {
	alias: string,
	content: string,

	target: string,
	
	flags: { [string]: true },
}

function install(data: installData)
	local packageContent = data.content
	
	local path, _ = packageUtils.getPackageDirectory()
	local decompressed = packageUtils.decode(packageContent)
	local decoded = serde.decode("json", decompressed)

	packageUtils.createPackageLink(path, data.alias, decoded)
end

return {
	install = install,
}
