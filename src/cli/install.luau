-- cli command for installing the dependencies of a stamper project
-- written by primiti-ve on github

local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local types = require("@src/types")
local toml = require("@src/utils/toml")

local commandConstructor = require("@src/constructors/cli/command")
local flagConstructor = require("@src/constructors/cli/flag")

local helpUtils = require("@src/utils/stamper/help")
local installingUtils = require("@src/utils/stamper/installing")
local networkingUtils = require("@src/utils/stamper/networking")
local packageUtils = require("@src/utils/stamper/package")

local tableUtils = require("@src/utils/table")

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
		if table.find(flags, `help`) then
			helpUtils.displaySpecific(`install`, _flags)

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
			print(`[stamper verbose] installing packages!`)
		end

		if table.find(flags, `clear`) then
			if table.find(flags, `verbose`) then
				print(`[stamper verbose] attempting to clear stamper_packages.`)
			end

			if fs.isDir("./stamper_packages") then
				if table.find(flags, `verbose`) then
					print(`[stamper verbose] removing stamper_packages.`)
				end

				fs.removeDir("./stamper_packages")
			else
				if table.find(flags, `verbose`) then
					print(`[stamper verbose] stamper_packages does not exist!`)
				end
			end
		end

		local file = fs.readFile("./stamper.toml")
		local data = toml.read(file)

		local dependencies = data.package.dependencies or {}

		packageUtils.getPackageDirectory()

		if tableUtils.getTableLength(dependencies) <= 0 then
			stdio.write(stdio.color("red"))

			print(`[stamper] no dependencies to install!`)
			print(`          add some with "stamper add".`)

			stdio.write(stdio.color("reset"))

			return
		end

		-- TODO: add more package targets; pesde, wally, git, etc
		for alias, dependency in pairs(dependencies) do
			local dependencyData: types.installData

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
						alias = alias,
						name = dependency.name,
						owner = dependency.owner,
						version = dependency.version,

						content = dependencyResult,
						target = `stamper`,

						flags = flags,
					} :: types.installData
				end
			end

			if dependencyData then
				installingUtils.install(dependencyData)
			end
		end
	end,
})

return command
