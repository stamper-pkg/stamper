local fs = require("@lune/fs")
local currentVersion = require("../version")

local commandConstructor = require("../constructors/cli/command")
local tableUtils = require("./table")

function displayGeneral()
	print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`)
	print("help menu")

	print("")

	print("usage:")
	print("  stamper [command] [flags]")

	print("")

	print("commands:")

	local commands = {} :: { [string]: commandConstructor.cliData }

	for _, name in pairs(fs.readDir("./src/cli")) do
		local prefix = ".luau"
		local sub = string.sub(name, string.len(name) - #prefix + 1, string.len(name))

		if sub == prefix then
			name = string.gsub(name, ".luau", "")

			local otherCommand = require(`../cli/{name}`)

			commands[otherCommand.displayPriority] = otherCommand
		end
	end

	for i = 1, tableUtils.getTableLength(commands) do
		local otherCommand = commands[i]

		if otherCommand.command ~= "t" then
			local text

			if otherCommand.displayCommand then
				text = "  stamper " .. otherCommand.displayCommand
			else
				text = "  stamper"
			end

			if otherCommand.flags then
				text = text .. " [flags]"
				text = text .. "\n"
				text = text .. "    flags:"

				for _, flag in pairs(otherCommand.flags) do
					local options = {}

					for option, description in pairs(flag.options) do
						table.insert(options, option)
					end

					tableUtils.sortFlags(options)

					text = text .. "\n"
					text = text .. "      " .. table.concat(options, ", ") .. ": " .. flag.description
				end
			end

			text = text .. "\n"

			print(text)
		end
	end
end

function displaySpecific(text: string, flags)
	text = text .. " [flags]"
	text = text .. "\n"
	text = text .. "  flags:"

	for _, flag in pairs(flags) do
		local options = {}

		for option, description in pairs(flag.options) do
			table.insert(options, option)
		end

		tableUtils.sortFlags(options)

		text = text .. "\n"
		text = text .. "    " .. table.concat(options, ", ") .. ": " .. flag.description
	end

	text = text .. "\n"

	print(text)
end

return {
	displayGeneral = displayGeneral,
	displaySpecific = displaySpecific,
}
