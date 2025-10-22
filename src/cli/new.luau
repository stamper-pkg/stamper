-- cli command for creating a new stamper project
-- written by primiti-ve on github

local fs = require("@lune/fs")
local toml = require("../utils/toml")

local promptConstructor = require("../constructors/prompt")
local commandConstructor = require("../constructors/cli/command")
local flagConstructor = require("../constructors/cli/flag")

local helpUtils = require("../utils./help")

local _flags = {
	help = flagConstructor("help", { "--help", "-h" }, "bring up the help menu for the command"),
	verbose = flagConstructor("verbose", { "--verbose", "-v" }, "enable verbose output"),
}

local command = commandConstructor({
	displayCommand = "new",
	displayPriority = 2,

	command = "new",
	description = "creates a new stamper project",

	flags = _flags,

	execute = function(args, flags)
		if flags.help then
			helpUtils.displaySpecific("stamper new", _flags)

			return
		end

		local verbose = flags.verbose or false

		local owner = promptConstructor("text", "who is the owner of your stamper project?", function(text: string)
			if not text then
				return false, "invalid package owner"
			end

			if tonumber(text) then
				return false, "package owner must be a string"
			end

			if #text < 1 or #text > 50 then
				return false, "package owner must be within 1 and 50 characters long"
			end

			return true, nil
		end)

		local name = promptConstructor("text", "what is the name of your stamper project?", function(text: string)
			if not text then
				return false, "invalid package name"
			end

			if tonumber(text) then
				return false, "package name must be a string"
			end

			if #text < 1 or #text > 50 then
				return false, "package name must be within 1 and 50 characters long"
			end

			return true, nil
		end)

		local description = promptConstructor("text", "what is the description of your stamper project?", function(text: string)
			if not text or text == "" then
				return true, nil
			end

			if #text < 1 or #text > 250 then
				return false, "invalid package description"
			end

			return true, nil
		end)

		local newProject = toml.write({
			header = {
				owner = owner,
				name = name,
			},

			package = {
				description = description,
				public = true,
			},
		})

		print(newProject)

		local confirmed = promptConstructor("confirm", "do these look good?")

		if confirmed then
			if verbose then
				print("confirmed creation of new stamper project")
			end

			if fs.isFile("./stamper.toml") then
				local delete = promptConstructor("confirm", "stamper.toml file already exists! would you like to delete it?")

				if delete then
					if verbose then
						print("deleting old stamper.toml")
					end

					fs.removeFile("./stamper.toml")

					if verbose then
						print("confirmed deletion of old stamper.toml")
					end
				else
					if verbose then
						print("user cancelled operation")
					end

					return
				end
			end
		else
			if verbose then
				print("cancelled operation")
			end

			return
		end

		fs.writeFile("./stamper.toml", newProject)

		if verbose then
			print("wrote new stamper.toml")
		end
	end,
})

return command
