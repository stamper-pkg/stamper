-- cli command for checking the current stamper version
-- written by primiti-ve on github

local fs = require("@lune/fs")
local currentVersion = require("../version")

local commandConstructor = require("../constructors/cli/command")
local flagConstructor = require("../constructors/cli/flag")

local _flags = {
	help = flagConstructor("help", { "--help", "-h" }, "bring up the stamper help menu"),
	version = flagConstructor("version", { "--version", "-v" }, "check the current stamper version"),
}

local command = commandConstructor({
	command = "misc",
	description = "blank stamper command, used for help and version",

	flags = _flags,

	execute = function(args, flags)
		if flags.help then
			print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch} help menu`)

			print("")

			print("usage:")
			print("  stamper [command] [flags]")

			print("")

			print("commands:")

			local commands = {}

			for _, name in pairs(fs.readDir("./src/cli")) do
				local prefix = ".luau"
				local sub = string.sub(name, string.len(name) - #prefix + 1, string.len(name))

				if sub == prefix then
					name = string.gsub(name, ".luau", "")
					commands[name] = require(`./{name}`)
				end
			end

			for _, otherCommand in pairs(commands) do
				if otherCommand.command ~= "t" then
					local text = "  stamper " .. otherCommand.command

					if otherCommand.flags then
						text = text .. " [flags]"
						text = text .. "\n"
						text = text .. "    flags:"

						for _, flag in pairs(otherCommand.flags) do
							local options = {}

							for option, description in pairs(flag.options) do
								table.insert(options, option)
							end

							text = text .. "\n"
							text = text .. "      " .. table.concat(options, ", ") .. ": " .. flag.description
						end
					end

					text = text .. "\n"

					print(text)
				end
			end
		elseif flags.version then
			print(`stamper {currentVersion.major}.{currentVersion.minor}.{currentVersion.patch}`)
		end
	end,
})

return command
