-- cli command for checking the current stamper version
-- written by primiti-ve on github

local configuration = require(`../configuration`)

local commandConstructor = require(`../constructors/cli/command`)
local flagConstructor = require(`../constructors/cli/flag`)

local helpUtils = require(`../utils/stamper/help`)

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the stamper help menu`),
	version = flagConstructor(`version`, { `--version`, `-v` }, `check the current stamper version`),
}

local command = commandConstructor({
	displayPriority = 1,

	command = `misc`,
	description = `global help menu + stamper version`,

	flags = _flags,

	execute = function(args, flags)
		if flags.help then
			helpUtils.displayGeneral()
		elseif flags.version then
			local currentVersion = configuration.currentVersion
			
			print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`)
		end
	end,
})

return command
