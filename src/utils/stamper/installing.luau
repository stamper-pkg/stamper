-- installing utils
-- written by primiti-ve on github

local serde = require("@lune/serde")

local types = require("@src/types")
local packageUtils = require("@src/utils/stamper/package")

function install(data: types.installData)
	local packageContent = data.content

	local path, _ = packageUtils.getPackageDirectory()
	local decompressed = packageUtils.decode(packageContent)
	local decoded = serde.decode("json", decompressed)

	packageUtils.createPackageLink(path, data.alias, data.name, decoded)
end

return {
	install = install,
}
