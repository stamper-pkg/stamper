-- stamper's entry point
-- written by primiti-ve on github

local process = require("@lune/process")
local stdio = require("@lune/stdio")

local levenshtein = require("@src/utils/levenshtein")

local args = process.args
local commands = require("@src/cli")

args = table.clone(args)

local commandName = args[1]
local command = commands[commandName]

if not command then
	if commandName then
		if string.sub(commandName, 1, 1) == `-` then
			commandName = `none`
			command = commands[commandName]
		else
			local commandNames = {}

			for _, otherCommand in pairs(commands) do
				table.insert(commandNames, {
					name = otherCommand.command,
					distance = levenshtein(otherCommand.command, commandName),
				})
			end

			table.sort(commandNames, function(a, b)
				return a.distance < b.distance
			end)

			local correctedCommand = commandNames[1]

			if correctedCommand.distance <= 2 then
				print(`{stdio.color("red")}[stamper]{stdio.color("reset")} no command named {stdio.color("yellow")}{commandName}{stdio.color("reset")} found!`)
				print(`          did you mean {stdio.color("yellow")}{correctedCommand.name}{stdio.color("reset")}?`)

				return
			end
		end
	end
else
	table.remove(args, 1)
end

if command then
	command.execute(args)
else
	print(`{stdio.color("red")}[stamper]{stdio.color("reset")} no command supplied!`)
end
