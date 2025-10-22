-- stamper's entry point
-- written by primiti-ve on github

local process = require("@lune/process")
local fs = require("@lune/fs")

local args = process.args
local commands = {}

args = table.clone(args)

for _, name in pairs(fs.readDir("./src/cli")) do
	local prefix = ".luau"
	local sub = string.sub(name, string.len(name) - #prefix + 1, string.len(name))

	if sub == prefix then
		name = string.gsub(name, ".luau", "")
		commands[name] = require(`./cli/{name}`)
	end
end

local commandName = args[1]
local command = commands[commandName]

if not command then
	commandName = "misc"
	command = commands[commandName]
else
	table.remove(args, 1)
end

if command then
	command.execute(args)
else
	print("no command supplied!")
end

return nil