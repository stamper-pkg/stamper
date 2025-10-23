-- installing utils
-- written by primiti-ve on github

local packageUtils = require("./package")

export type installData = {
	alias: string,
	content: string,

	target: string,
	
	flags: { [string]: true },
}

function install(data: installData)
	local packageContent = data.content

	packageContent = packageUtils.encode(packageContent)
	
	local path, _ = packageUtils.getPackageDirectory()
	local decompressed = packageUtils.decode(packageContent)

	packageUtils.createPackageLink(path, data.alias, decompressed)
end

return {
	install = install,
}
