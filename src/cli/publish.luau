-- cli command for publishing a stamper project to the registry
-- written by primiti-ve on github

local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local types = require("@src/types")
local toml = require("@src/utils/toml")

local promptConstructor = require("@src/constructors/prompt")
local commandConstructor = require("@src/constructors/cli/command")
local flagConstructor = require("@src/constructors/cli/flag")

local helpUtils = require("@src/utils/stamper/help")
local networkingUtils = require("@src/utils/stamper/networking")

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the help menu for the command`),
	verbose = flagConstructor(`verbose`, { `--verbose`, `-v` }, `enable verbose output`),
}

local command = commandConstructor({
	displayCommand = `publish`,
	displayPriority = 4,

	command = `publish`,
	description = `publishes a stamper project to the registry`,

	flags = _flags,

	execute = function(args, flags)
		if table.find(flags, `help`) then
			helpUtils.displaySpecific(`publish`, _flags)

			return
		end

		if not fs.isFile(`./stamper.toml`) then
			stdio.write(stdio.color("red"))

			print(`[stamper] stamper.toml file does not exist!`)
			print(`          create one with "stamper new".`)

			stdio.write(stdio.color("reset"))

			return
		end

		if table.find(flags, `verbose`) then
			print(`[stamper verbose] publishing package!`)
		end

		local file = fs.readFile(`./stamper.toml`)
		local data = toml.read(file) :: types.packageData

		if not data.package.public then
			stdio.write(stdio.color("red"))

			print(`[stamper] package is set to private!`)
			print(`          set "public" to true before running this again.`)

			stdio.write(stdio.color("reset"))

			return
		end

		print()
		print(file)

		local confirm = promptConstructor(`confirm`, `[stamper] are these values okay?`)

		if confirm then
			if table.find(flags, `verbose`) then
				print(`[stamper verbose] user confirmed publishing!`)
			end

			data.flags = flags

			local result = networkingUtils.new(data)

			print(result.message)
		else
			if table.find(flags, `verbose`) then
				print(`[stamper verbose] user cancelled publishing.`)
			end
		end
	end,
})

return command
