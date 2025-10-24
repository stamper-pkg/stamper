-- cli command for "stamper --help" and "stamper --version"
-- written by primiti-ve on github

local configuration = require("@src/configuration")

local commandConstructor = require("@src/constructors/cli/command")
local flagConstructor = require("@src/constructors/cli/flag")

local helpUtils = require("@src/utils/stamper/help")

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the stamper help menu`),
	version = flagConstructor(`version`, { `--version`, `-v` }, `check the current stamper version`),
}

local command = commandConstructor({
	displayPriority = 1,

	command = `none`,
	description = `global help menu + stamper version`,

	flags = _flags,

	execute = function(args, flags)
		if table.find(flags, `help`) then
			helpUtils.displayGeneral()
		elseif table.find(flags, "version") then
			local currentVersion = configuration.currentVersion

			print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`)
		end
	end,
})

return command
