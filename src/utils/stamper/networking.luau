-- networking utils
-- written by primiti-ve on github

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local net = require("@lune/net")

local configuration = require("../../configuration")

local types = require("../../types")
local spin = require("../../utils/spin")

local packageUtils = require("./package")

local defaultError = "{status_code} ({response_body})"
local defaultErrors = {
	["404"] = "404 (did you spell the package details correctly?)",
}

function throwError(response: net.FetchResponse)
	local statusCode, body = response.statusCode, response.body
	local errorMessage = defaultError

	if body then
		body = serde.decode("json", body)
	else
		if defaultErrors[tostring(statusCode)] then
			errorMessage = defaultErrors[tostring(statusCode)]
		else
			body = {
				error = "No error message found",
			}
		end
	end

	if errorMessage then
		errorMessage = string.gsub(errorMessage, "{status_code}", tostring(statusCode))
		errorMessage = string.gsub(errorMessage, "{response_body}", string.lower(body.error))
	end

	stdio.write(stdio.color("red"))
	print(`[stamper] request failed: {errorMessage}`)
	stdio.write(stdio.color("reset"))
end

function get(data: types.packageData)
	local owner = string.gsub(data.header.owner, `"`, ``)
	local name = string.gsub(data.header.name, `"`, ``)
	local packageVersion = string.gsub(data.package.version, `"`, ``)

	print(`[stamper] getting package {owner}/{name} {packageVersion}! please wait...`)

	local stop = spin.create(spin.animations.material)
	local response = net.request({
		url = `{configuration.baseUrl}/packages/get`,

		query = {
			owner = owner,
			name = name,
			version = packageVersion,
		},
	})

	stop()

	if response.ok then
		print(`[stamper] received package {owner}/{name}!`)

		local body = response.body

		body = packageUtils.decode(body)

		if table.find(data.flags, `verbose`) then
			print(`[stamper verbose] package body: {body}`)
		end

		return body
	else
		throwError(response)

		return nil
	end
end

function new(data: types.packageData)
	local owner = string.gsub(data.header.owner, `"`, ``)
	local name = string.gsub(data.header.name, `"`, ``)
	local packageVersion = string.gsub(data.package.version, `"`, ``)

	print(`[stamper] publishing package {owner}/{name} {packageVersion} - please wait...`)
	print()

	local srcPath = data.build.src
	local buildExcludes = serde.decode("json", data.build.excludes) or {}

	local content = {
		src = {
			class = "folder",
			children = {},
		},
	}

	local function traverse(directoryPath: string, parentNode)
		local items = fs.readDir(directoryPath)

		for _, itemName in pairs(items) do
			if table.find(buildExcludes, itemName) then
				continue
			end

			local itemPath = `{directoryPath}/{itemName}`
			local node = {}

			if fs.isDir(itemPath) then
				node.class = "folder"
				node.children = {}

				parentNode.children[itemName] = node

				traverse(itemPath, node)
			elseif fs.isFile(itemPath) then
				if itemName:match("%.client%.luau$") then
					node.class = "client"
				elseif itemName:match("%.server%.luau$") then
					node.class = "server"
				elseif itemName:match("%.luau$") then
					node.class = "module"
				else
					node.class = "file"
				end

				node.contents = fs.readFile(itemPath)
				parentNode.children[itemName:gsub("%..*$", "")] = node
			end
		end
	end

	traverse(srcPath, content.src)

	local stop = spin.create(spin.animations.material)
	local response = net.request({
		method = "POST",
		url = `{configuration.baseUrl}/packages/new`,

		query = {
			owner = owner,
			name = name,
			version = packageVersion,
		},

		body = serde.encode("json", {
			content = packageUtils.encode(content),
		}),
	})

	stop()

	if response.ok then
		if table.find(data.flags, `verbose`) then
			print(`[stamper verbose] published package!`)
			print(`[stamper verbose] {response.body}`)
		end

		return response.body
	else
		throwError(response)

		return nil
	end
end

return {
	get = get,
	new = new,
}
