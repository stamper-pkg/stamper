-- stamper build script
-- written by primiti-ve on github

local process = require("@lune/process")
local fs = require("@lune/fs")

export type os = "Windows" | "MacOS" | "Linux"
export type arch = "x86_64" | "aarch64"

return function(os: os, arch: arch)
	local exeName = `stamper_{os:lower()}_{arch:lower()}.exe`
	local exePath = `releases/{exeName}`
	local zipPath = `releases/stamper_{os:lower()}_{arch:lower()}.zip`

	process.exec("darklua", { "process", "src/init.luau", "build" }, {
		stdio = "inherit",
	})

	process.exec("lune", { "build", "build/init.luau", "-o", exePath, "-t", `{os}-{arch}` }, {
		stdio = "inherit",
	})

	if fs.isFile(exePath) then
		print(`zipping {exeName} into {zipPath}...`)

		process.exec("zip", { "-j", zipPath, exePath }, {
			stdio = "inherit",
		})

		print(`created {zipPath}`)

		fs.removeFile(exePath)
	else
		error(`build failed: {exePath} not found`)
	end
end
