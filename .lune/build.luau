-- stamper build script
-- written by primiti-ve on github

local process = require("@lune/process")

export type os = "Windows" | "MacOS" | "Linux"
export type arch = "x86_64" | "aarch64"

return function(os: os, arch: arch)
	process.exec("darklua", { "process", "src/init.luau", "build" }, {
		stdio = "inherit",
	})

	process.exec("lune", { "build", "build/init.luau", "-o", `releases/stamper_{os:lower()}_{arch:lower()}.exe`, "-t", `{os}-{arch}` }, {
		stdio = "inherit",
	})
end
