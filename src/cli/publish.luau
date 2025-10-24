-- cli command for publishing a stamper project to the registry
-- written by primiti-ve on github

local fs = require(`@lune/fs`)

local types = require("../types")
local toml = require(`../utils/toml`)

local promptConstructor = require(`../constructors/prompt`)
local commandConstructor = require(`../constructors/cli/command`)
local flagConstructor = require(`../constructors/cli/flag`)

local helpUtils = require(`../utils/stamper/help`)
local networkingUtils = require(`../utils/stamper/networking`)

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
		if flags.help then
			helpUtils.displaySpecific(`publish`, _flags)

			return
		end

		if not fs.isFile(`./stamper.toml`) then
			print(`[stamper] stamper.toml file does not exist`)
			print(`          please create one with "stamper new"`)

			return
		end

		if flags.verbose then
			print(`[stamper verbose] publishing package`)
		end

		local file = fs.readFile("./stamper.toml")
		local data = toml.read(file) :: types.packageData

		if not data.package.public then
			print(`[stamper] package is set to private`)

			return
		end

		print()
		print(file)

		local confirm = promptConstructor(
			"confirm",
			`[stamper] are these values okay?`
		)

		if confirm then
			if flags.verbose then
				print(`[stamper verbose] user confirmed publishing`)
			end

			data.flags = flags

			local result = networkingUtils.new(data)

			print(result)
		else
			if flags.verbose then
				print(`[stamper verbose] user cancelled publishing`)
			end
		end
	end,
})

return command
