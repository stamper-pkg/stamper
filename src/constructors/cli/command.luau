-- cli command constructor
-- written by primiti-ve on github

local flagConstructor = require("@constructors/cli/flag")

export type cliData = {
	command: string,
	description: string,
	
	flags: { [string]: flagConstructor.flag },

	execute: (any) -> any,
}

return function(data: cliData)
	local command = {}

	command.command = data.command
	command.description = data.description

	command.flags = data.flags

	function command.execute(args)
		local flags = {}
		local i = 1

		while i <= #args do
			local arg = args[i]

			for flagName, flag in pairs(command.flags) do
				if string.sub(arg, 1, 1) == "-" then
					table.remove(args, i)
				end

				for name in pairs(flag.options) do
					if name == arg then
						flags[flagName] = true
						table.remove(args, i)
					end
				end
			end

			i += 1
		end

		return data.execute(args, flags)
	end

	return command
end
