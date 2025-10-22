-- cli command for creating a new stamper project
-- written by primiti-ve on github

local fs = require(`@lune/fs`)
local toml = require(`../utils/toml`)

local commandConstructor = require(`../constructors/cli/command`)
local flagConstructor = require(`../constructors/cli/flag`)

local helpUtils = require(`../utils/help`)

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the help menu for the command`),
	verbose = flagConstructor(`verbose`, { `--verbose`, `-v` }, `enable verbose output`),
}

local command = commandConstructor({
	displayCommand = `install`,
	displayPriority = 2,

	command = `install`,
	description = `installs all dependencies of a stamper project`,

	flags = _flags,

	execute = function(args, flags)
		if flags.help then
			helpUtils.displaySpecific(`install`, _flags)

			return
		end

		if not fs.isFile(`./stamper.toml`) then
			print(`[stamper] stamper.toml file does not exist`)
			print(`          please create one with "stamper new"`)

			return
		end

		if flags.verbose then 
            print(`[stamper verbose] creating`)
		end

        local file = fs.readFile("./stamper.toml")
        local data = toml.read(file)

        local dependencies = data.package.dependencies or {}

        for alias, dependency in pairs(dependencies) do
            print(alias, dependency)
        end
	end,
})

return command
