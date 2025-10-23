-- spinner animations for lune
-- written by lettuce-magician on github

local stdio = require("@lune/stdio")
local task = require("@lune/task")
local animations = require("./spin/animations")

local write = stdio.write
local spawn = task.spawn
local wait = task.wait

type spinner = {
	frames: { string },

	-- in miliseconds
	interval: number,
}

local DEFAULT_SPINNER = animations.line

local spin = {}
spin.animations = animations

-- used to convert intervals
local function msToSeconds(ms: number)
	return ms / 1000
end

-- this package relies on ansi escape codes to update animations and clearing them.
-- see: https://gist.github.com/ConnerWill/d4b6c776b509add763e17f9f113fd25b
local function esc(str: string)
	write("\27" .. str)
end

-- stores the cursor's current position
local function saveCursor()
	esc("[s")
end

-- restores the saved cursor's position
local function restoreCursor()
	esc("[u")
end

-- \b moves the terminal cursor 1 column behind.
local function backspace(len: number)
	return write(("\b"):rep(len))
end

-- creates and starts a spinner animation.
--
-- by default, after finishing, the function will not write a newline character.
function spin.create(spinner: spinner?): () -> ()
	local animation = (spinner or DEFAULT_SPINNER)
	local interval = msToSeconds(animation.interval)
	local running = true

	local len = 0
    local uLen = 0
	spawn(function()
		while running do
			for i = 1, #animation.frames do
				if not running then
					break
				end

				local frame = animation.frames[i]

				write(frame)

				len = #frame

                -- it is needed to store the utf8 length of the frame for cleaning.
                -- \b moves 1 byte behind instead of 1 character behind,
                -- because of this, we need to use utf8.len to obtain the number of characters in the string,
                -- not the number bytes that form it. (the # operator returns the string's byte count).
                uLen = utf8.len(frame)

				-- utf8 returns nil if one of the codepoints is invalid
				assert(len ~= nil, "invalid utf8 codepoint for spinner at frame #" .. i)

				wait(interval)

				-- additional break for accuracy
				if not running then
					break
				end

				-- returns to the beginning of the animation to redraw it again
				backspace(len)
			end
		end
	end)

	-- this function stops the animation while also cleaning it up (unless noCleanup is true).
	return function(noCleanup: boolean?)
		if not running then
			return
		end

		running = false

		if noCleanup == true then
			return
		end

		-- cleanup has to be in this thread,
		-- otherwise it would cause a race time condition.

		-- goes back to the start of the loading bar
		backspace(len)
		saveCursor()
		-- overwrites whatever was written
		write((" "):rep(uLen))
		restoreCursor()
	end
end

-- yields the current thread's execution until `fn` is finished executing.
--
-- while that happens, a spinner is created and stops when the function ends.
function spin.await<R...>(spinner: spinner?, fn: () -> R..., noCleanup: boolean?): R...
	local thisThread = coroutine.running()

	local stop = spin.create(spinner)

	-- should this be defered?
	spawn(function()
		-- this will execute the function first and then return the values to the yield
		coroutine.resume(thisThread, fn())
	end)

	local result = { coroutine.yield() }

	stop(noCleanup)

	return unpack(result)
end

-- syntatic sugar for creating a spinner, task.waiting and stopping it right after.
function spin.interval(spinner: spinner?, t: number, noCleanup: boolean?)
	local stop = spin.create(spinner)

	local total = wait(t)

	stop(noCleanup)

	return total
end

return spin