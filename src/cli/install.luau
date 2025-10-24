-- cli command for installing the dependencies of a stamper project
-- written by primiti-ve on github

local fs = require(`@lune/fs`)
local toml = require(`../utils/toml`)

local commandConstructor = require(`../constructors/cli/command`)
local flagConstructor = require(`../constructors/cli/flag`)

local helpUtils = require(`../utils/stamper/help`)
local installingUtils = require(`../utils/stamper/installing`)
local networkingUtils = require(`../utils/stamper/networking`)

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the help menu for the command`),
	verbose = flagConstructor(`verbose`, { `--verbose`, `-v` }, `enable verbose output`),
	clear = flagConstructor(`clear`, { `--clear`, `-c` }, "clear stamper_packages before installing"),
}

local command = commandConstructor({
	displayCommand = `install`,
	displayPriority = 3,

	command = `install`,
	description = `installs the dependencies of a stamper project`,

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
			print(`[stamper verbose] installing packages`)
		end

		if flags.clear then
			if flags.verbose then
				print(`[stamper verbose] attempting to clear stamper_packages`)
			end

			if fs.isDir("./stamper_packages") then
				if flags.verbose then
					print(`[stamper verbose] removing stamper_packages`)
				end

				fs.removeDir("./stamper_packages")
			else
				if flags.verbose then
					print(`[stamper verbose] stamper_packages does not exist`)
				end
			end
		end

		local file = fs.readFile("./stamper.toml")
		local data = toml.read(file)

		local dependencies = data.package.dependencies or {}

		-- TODO: add more package targets; pesde, wally, git, etc
		for alias, dependency in pairs(dependencies) do
			local dependencyData: installingUtils.installData

			if dependency.owner and dependency.name then
				local dependencyResult = {
					header = {
						name = dependency.name,
						owner = dependency.owner,
						description = "",
					},

					package = {
						version = dependency.version,
					},

					flags = flags,
				}

				dependencyResult = networkingUtils.get(dependencyResult)

				if dependencyResult ~= nil then
					dependencyData = {
						content = dependencyResult,
						alias = alias,

						target = `stamper`,

						flags = flags,
					} :: installingUtils.installData
				end
			end

			if dependencyData then
				installingUtils.install(dependencyData)
			end
		end
	end,
})

return command
