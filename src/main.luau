-- stamper's entry point
-- written by primiti-ve on github

local process = require("@lune/process")
local fs = require("@lune/fs")

local args = process.args
local commands = {}

args = table.clone(args)

for _, name in pairs(fs.readDir("./src/cli")) do
	name = string.gsub(name, ".luau", "")

	if name ~= "constructor" then
		commands[name] = require(`./cli/{name}`)
	end
end

local commandName = args[1]
local command = commands[commandName]

if command then
	table.remove(args, 1)

	command.execute(args)
else
	if commandName then 
		print("unknown command '" .. tostring(commandName) .. "'!")
	else
		print("no command supplied!")
	end
end

return nil