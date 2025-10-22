-- lune stdio.prompt wrapper
-- written by primiti-ve on github

local stdio = require("@lune/stdio")

return function(kind: string, message: string, guard: ((string) -> (boolean, string?))?)
	local accepted, acceptedText = false, ""

	repeat
		local text = stdio.prompt(kind, message)

		if not guard then
			return text
		end

		local result, errorMessage = guard(text)

		if not result then
			stdio.write(stdio.color("red"))
			print(errorMessage)
			stdio.write(stdio.color("reset"))
		else
			accepted = true
			acceptedText = text
		end
	until accepted

	return acceptedText
end
