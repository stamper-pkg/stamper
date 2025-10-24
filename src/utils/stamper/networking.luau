-- networking utils
-- written by primiti-ve on github

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local net = require("@lune/net")

local configuration = require("../../configuration")

local types = require("../../types")
local spin = require("../../utils/spin")

local packageUtils = require("./package")

local defaultError = "{status_code} (no error message found)"
local errorMessages = {
	["404"] = "404 (did you spell the package details correctly?)",
}

function throwError(statusCode: number)
	local errorMessage = errorMessages[tostring(statusCode)]

	if not errorMessage then
		errorMessage = defaultError
		errorMessage = string.gsub(errorMessage, "{status_code}", tostring(statusCode))
	end

	print(`[stamper] request failed: {errorMessage}`)
end

function get(data: types.packageData)
	print(`[stamper] getting package {data.header.owner}/{data.header.name}! please wait...`)

	local stop = spin.create(spin.animations.material)
	local response = net.request({
		url = `{configuration.baseUrl}/packages/get`,

		query = {
			owner = data.header.owner,
			name = data.header.name,
			version = data.package.version,
		},
	})

	stop()

	if response.ok then
		print(`[stamper] received package {data.header.owner}/{data.header.name}!`)

		local body = response.body

		body = packageUtils.decode(body)

		if data.flags.verbose then
			print(`[stamper verbose] package body: {body}`)
		end

		return body
	else
		throwError(response.statusCode)

		return nil
	end
end

function new(data: types.packageData)
	print(`[stamper] publishing package {data.header.owner}/{data.header.name} {data.package.version} - please wait...`)
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
			owner = data.header.owner,
			name = data.header.name,
			version = data.package.version,
		},

		body = serde.encode("json", {
			content = packageUtils.encode(content),
		}),
	})

	stop()

	if response.ok then
		if data.flags.verbose then
			print(`[stamper verbose] published package!`)
			print(`[stamper verbose] {response.body}`)
		end

		return response.body
	else
		throwError(response.statusCode)

		return nil
	end
end

return {
	get = get,
	new = new,
}
