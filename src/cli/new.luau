-- cli command for creating a new stamper project
-- written by primiti-ve on github

local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local configuration = require("@src/configuration")

local stamper_toml = require("@src/templates/stamper_toml")

local promptConstructor = require("@src/constructors/prompt")
local commandConstructor = require("@src/constructors/cli/command")
local flagConstructor = require("@src/constructors/cli/flag")

local helpUtils = require("@src/utils/stamper/help")

local projectTypes = {
	`library`,
	`game`,
}

local publicSettings = {
	[`library`] = true,
	[`game`] = false,
}

local _flags = {
	help = flagConstructor(`help`, { `--help`, `-h` }, `bring up the help menu for the command`),
	verbose = flagConstructor(`verbose`, { `--verbose`, `-v` }, `enable verbose output`),
}

local command = commandConstructor({
	displayCommand = `new`,
	displayPriority = 2,

	command = `new`,
	description = `creates a new stamper project`,

	flags = _flags,

	execute = function(args, flags)
		if table.find(flags, `help`) then
			helpUtils.displaySpecific(`new`, _flags)

			return
		end

		if fs.isFile(`./stamper.toml`) then
			print(`{stdio.color("red")}[stamper]{stdio.color("reset")} stamper.toml file already exists!`)

			return
		end

		local projectType = promptConstructor(
			`select`,
			`[stamper] what would you like your new stamper project to be? (required)`,
			function(index: number)
				local text = projectTypes[index]

				if not text then
					return false, `provided type is not a valid type.`
				end

				return true, nil
			end,
			projectTypes
		)

		projectType = projectTypes[projectType]

		local owner = promptConstructor(
			`text`,
			`[stamper] who is the owner of your new stamper {projectType}? (required)`,
			function(text: string)
				if not text then
					return false, `invalid package owner.`
				end

				if tonumber(text) then
					return false, `package owner must be a string.`
				end

				if #text < 1 or #text > 50 then
					return false, `package owner must be within 1 and 50 characters long.`
				end

				return true, nil
			end
		)

		local name = promptConstructor(
			`text`,
			`[stamper] what is the name of your new stamper {projectType}? (required)`,
			function(text: string)
				if not text then
					return false, `invalid package name.`
				end

				if tonumber(text) then
					return false, `package name must be a string.`
				end

				if #text < 1 or #text > 50 then
					return false, `package name must be within 1 and 50 characters long.`
				end

				return true, nil
			end
		)

		local description = promptConstructor(
			`text`,
			`[stamper] what is the description of your new stamper {projectType}? (optional)`,
			function(text: string)
				if not text or text == `` then
					return true, nil
				end

				if #text < 1 or #text > 250 then
					return false, `invalid package description.`
				end

				return true, nil
			end
		)
		
		local newProject = stamper_toml

		newProject = string.gsub(newProject, "{package_name}", name)
		newProject = string.gsub(newProject, "{package_owner}", owner)
		newProject = string.gsub(newProject, "{package_description}", description)

		newProject = string.gsub(newProject, "{default_registry}", configuration.baseUrl)

		newProject = string.gsub(newProject, "{package_type}", projectType)
		newProject = string.gsub(newProject, "{package_public}", tostring(publicSettings[projectType]))

		print()
		print(newProject)

		local confirmed = promptConstructor(`confirm`, `do these options look good? (required)`)

		if confirmed then
			if table.find(flags, `verbose`) then
				print(`[stamper verbose] confirmed creation of new stamper project!`)
			end

			if fs.isFile(`./stamper.toml`) then
				local delete = promptConstructor(
					`confirm`,
					`stamper.toml file already exists! would you like to delete it? (optional)`
				)

				if delete then
					if table.find(flags, `verbose`) then
						print(`[stamper verbose] deleting old stamper.toml.`)
					end

					fs.removeFile(`./stamper.toml`)

					if table.find(flags, `verbose`) then
						print(`[stamper verbose] deleted old stamper.toml!`)
					end
				else
					if table.find(flags, `verbose`) then
						print(`[stamper verbose] user cancelled operation!`)
					end

					return
				end
			end
		else
			if table.find(flags, `verbose`) then
				print(`[stamper verbose] user cancelled operation!`)
			end

			return
		end
		
		fs.writeFile(`./stamper.toml`, newProject)

		if table.find(flags, `verbose`) then
			print(`[stamper verbose] wrote new stamper.toml!`)
		end

		print(`[stamper] run "stamper install" to get your packages.`)
	end,
})

return command
