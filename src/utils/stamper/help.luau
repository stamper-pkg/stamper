-- help utils
-- written by primiti-ve on github

local configuration = require("@src/configuration")

local commandConstructor = require("@src/constructors/cli/command")
local tableUtils = require("@src/utils/table")

function displayGeneral()
	local currentVersion = configuration.currentVersion

	print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`)
	print(`help menu`)

	print(``)

	print(`usage:`)
	print(`  stamper [command] [flags]`)

	print(``)

	print(`commands:`)

	local commandsList = {} :: { [string]: commandConstructor.cliData }
	local commands = {}

	for _, otherCommand in pairs(commandsList) do
		table.insert(commands, otherCommand.displayPriority, otherCommand)
	end

	for i = 1, tableUtils.getTableLength(commands) do
		local otherCommand = commands[i]
		local text

		if otherCommand.displayCommand then
			text = `  stamper ` .. otherCommand.displayCommand
		else
			text = `  stamper`
		end

		if otherCommand.flags then
			text = `{text} [flags]`
		end

		text = `{text}\n`
		text = `{text}    {otherCommand.description}`
		text = `{text}\n`

		if otherCommand.flags then
			local flags = {}

			text = `{text}\n`
			text = `{text}    flags:`

			for flagName, flag in pairs(otherCommand.flags) do
				if flags[flagName] then
					continue
				end

				flags[flagName] = true

				local options = {}

				for option, description in pairs(flag.options) do
					table.insert(options, option)
				end

				tableUtils.sortFlags(options)

				text = `{text}\n`
				text = `{text}      ` .. table.concat(options, `, `) .. `: ` .. flag.description
			end
		end

		text = `{text}\n`

		print(text)
	end
end

function displaySpecific(command: string, flags)
	local text = `stamper {command}`
	text = `{text} [flags]`
	text = `{text}\n`
	text = `{text}  flags:`

	for _, flag in pairs(flags) do
		local options = {}

		for option, description in pairs(flag.options) do
			table.insert(options, option)
		end

		tableUtils.sortFlags(options)

		text = `{text}\n`
		text = `{text}    ` .. table.concat(options, `, `) .. `: ` .. flag.description
	end

	text = `{text}\n`

	print(text)
end

return {
	displayGeneral = displayGeneral,
	displaySpecific = displaySpecific,
}
