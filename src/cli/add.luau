-- cli command for adding dependencies to stamper.toml
-- written by primiti-ve on github

local fs = require(`@lune/fs`)

local promptConstructor = require(`../constructors/prompt`)
local commandConstructor = require(`../constructors/cli/command`)
local flagConstructor = require(`../constructors/cli/flag`)

local helpUtils = require(`../utils/stamper/help`)

local dependencyTargets = {
	"stamper",
}

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the help menu for the command`),
	verbose = flagConstructor(`verbose`, { `--verbose`, `-v` }, `enable verbose output`),
}

local command = commandConstructor({
	displayCommand = `add`,
	displayPriority = 5,

	command = `add`,
	description = `adds a dependency to stamper.toml`,

	flags = _flags,

	execute = function(args, flags)
		if flags.help then
			helpUtils.displaySpecific(`add`, _flags)

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

		local file = fs.readFile("./stamper.toml")

		local sectionPattern = "%[package%.dependencies%]"
		local sectionStart = string.find(file, sectionPattern)

		if not sectionStart then
			print(`[stamper] stamper.toml does not have a [package.dependencies] section!`)

			return
		end

		local dependencyTarget = promptConstructor(
			"select",
			"[stamper] what target is the stamper dependency?",
			function(index: number)
				local text = dependencyTargets[index]

				if not text then
					return false, "provided target is not a valid target"
				end

				return true, nil
			end,
			dependencyTargets
		)

		dependencyTarget = dependencyTargets[dependencyTarget]

		if dependencyTarget == "stamper" then
			local owner = promptConstructor(
				`text`,
				`[stamper] who is the owner of the stamper dependency?`,
				function(text: string)
					if not text then
						return false, `invalid dependency owner`
					end

					if tonumber(text) then
						return false, `dependency owner must be a string`
					end

					if #text < 1 or #text > 50 then
						return false, `dependency owner must be within 1 and 50 characters long`
					end

					return true, nil
				end
			)

			local name = promptConstructor(
				`text`,
				`[stamper] what is the name of the stamper dependency?`,
				function(text: string)
					if not text then
						return false, `invalid dependency name`
					end

					if tonumber(text) then
						return false, `dependency name must be a string`
					end

					if #text < 1 or #text > 50 then
						return false, `dependency name must be within 1 and 50 characters long`
					end

					return true, nil
				end
			)

			local dependencyVersion = promptConstructor(
				`text`,
				`[stamper] what is the version of the stamper dependency? (leaving blank will default to latest)`
			)

			if dependencyVersion == "" then
				dependencyVersion = "latest"
			end

			local dependencyData = string.format(
				'%s = { owner = "%s", name = "%s", version = "%s" }',
				name,
				owner,
				name,
				dependencyVersion
			)

			local before, depsSection, after = file:match("^(.-)%[package%.dependencies%]%s*(.-)\n%[.-%]\n(.*)$")

			if not before then
				before, depsSection = file:match("^(.-)%[package%.dependencies%]%s*(.*)$")
				after = ""
			end

			depsSection = depsSection:gsub("^%s+", ""):gsub("%s+$", "")

			local newDepsSection

			if depsSection == "" then
				newDepsSection = dependencyData
			else
				newDepsSection = depsSection .. "\n" .. dependencyData
			end

			file = string
				.format("%s[package.dependencies]\n%s\n\n%s", before, newDepsSection, after)
				:gsub("\n\n\n+", "\n\n")
		end

		fs.writeFile("./stamper.toml", file)
	end,
})

return command
