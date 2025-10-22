-- cli command for creating a new stamper project
-- written by primiti-ve on github

local fs = require("@lune/fs")

local prompt = require("@utils/prompt")
local toml = require("@utils/toml")

local commandConstructor = require("@constructors/cli/command")
local flagConstructor = require("@constructors/cli/flag")

local new = commandConstructor({
	command = "new",

	flags = {
		verbose = flagConstructor("verbose", { "--verbose", "-v" }, "Enable verbose output"),
	},

	execute = function(args, flags)
		local verbose = flags.verbose or false

		local owner = prompt("text", "who is the owner of your stamper project?", function(text)
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

		local name = prompt("text", "what is the name of your stamper project?", function(text)
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

		local description = prompt("text", "what is the description of your stamper project?", function(text)
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

		local confirmed = prompt("confirm", "do these look good?")

		if confirmed then
			if verbose then
				print("confirmed creation of new stamper project")
			end

			fs.writeFile("./stamper.toml", newProject)
		else
			if verbose then
				print("cancelled operation")
			end
		end
	end,
})

return new
