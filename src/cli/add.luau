-- cli command for adding dependencies to stamper.toml
-- written by primiti-ve on github

local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local promptConstructor = require("@src/constructors/prompt")
local commandConstructor = require("@src/constructors/cli/command")
local flagConstructor = require("@src/constructors/cli/flag")

local helpUtils = require("@src/utils/stamper/help")
local miscUtils = require("@src/utils/misc")

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
		if table.find(flags, `help`) then
			helpUtils.displaySpecific(`add`, _flags)

			return
		end

		if not fs.isFile(`./stamper.toml`) then
			print(`{stdio.color("red")}[stamper]{stdio.color("reset")} stamper.toml file does not exist`)
			print(`          please create one with "stamper new"`)

			return
		end

		if table.find(flags, `verbose`) then
			print(`[stamper verbose] installing packages`)
		end

		local file = fs.readFile("./stamper.toml")

		local sectionPattern = "%[package%.dependencies%]"
		local sectionStart = string.find(file, sectionPattern)

		if not sectionStart then
			print(`{stdio.color("red")}[stamper]{stdio.color("reset")} stamper.toml does not have a [package.dependencies] section!`)

			return
		end

		local dependencyTarget = promptConstructor(
			"select",
			"[stamper] what target is the stamper dependency? (required)",
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
				`[stamper] who is the owner of the stamper dependency? (required)`,
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
				`[stamper] what is the name of the stamper dependency? (required)`,
				function(text: string)
					if not text then
						return false, `invalid dependency name.`
					end

					if tonumber(text) then
						return false, `dependency name must be a string.`
					end

					if #text < 1 or #text > 50 then
						return false, `dependency name must be within 1 and 50 characters long.`
					end

					return true, nil
				end
			)

			local dependencyVersion = promptConstructor(
				`text`,
				`[stamper] what is the version of the stamper dependency? (optional, leaving blank will default to latest)`
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
			
			file = miscUtils.append(file, "[package.dependencies]", dependencyData)
		end

		fs.writeFile("./stamper.toml", file)
	end,
})

return command
