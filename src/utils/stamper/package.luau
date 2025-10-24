-- package utils
-- written by primiti-ve on github

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local compressor = require("../compressor")
local packageTemplate = require("../../templates/package")

local suffix = `.stamper`
local encodeFormat: serde.EncodeDecodeFormat = "json"

function getPackageDirectory()
	local cwd = process.cwd
	local path = `{cwd}stamper_packages`

	if not fs.isDir(path) then
		fs.writeDir(path)
	end

	if not fs.isDir(`{path}/{suffix}`) then
		fs.writeDir(`{path}/{suffix}`)
	end

	return path, fs.readDir(path)
end

function createPackageLink(path: string, alias: string, name: string, data: any)
	if not path or not data then
		return
	end

	alias = string.gsub(alias, `"`, ``)
	name = string.gsub(name, `"`, ``)

	local packageRoot = `{path}/{suffix}/{name}`

	if fs.isDir(packageRoot) then
		fs.removeDir(packageRoot)
	elseif fs.isFile(packageRoot) then
		fs.removeFile(packageRoot)
	end

	local function writeNode(node, currentPath)
		if not node or type(node) ~= "table" then
			return
		end

		local classType = node.class

		if classType == "folder" then
			fs.writeDir(currentPath)
		elseif classType == "client" then
			fs.writeFile(`{currentPath}.client.luau`, node.contents or "")
		elseif classType == "server" then
			fs.writeFile(`{currentPath}.server.luau`, node.contents or "")
		elseif classType == "module" then
			fs.writeFile(`{currentPath}.luau`, node.contents or "")
		end

		if node.children then
			for childName, childNode in pairs(node.children or {}) do
				local childPath = `{currentPath}/{childName}`

				writeNode(childNode, childPath)
			end
		end
	end

	for nodeName, node in pairs(data) do
		local basePath = `{packageRoot}/{nodeName}`

		writeNode(node, basePath)
	end

	local packageDirector = packageTemplate

	packageDirector = string.gsub(packageDirector, "{package_name}", name)

	fs.writeFile(`{path}/{alias}.luau`, packageDirector)

	print(`[stamper] package "{alias}" written successfully to {packageRoot}`)
end

function encode(data: any): string?
	if data == nil then
		return nil
	end

	local encoded = serde.encode(encodeFormat, data)

	encoded = compressor.compress(encoded)

	return encoded
end

function decode(data: string): any
	if not data then
		return nil
	end

	local decoded = compressor.decompress(data)

	if typeof(decoded) ~= "string" then
		decoded = serde.decode(encodeFormat, decoded)
	end

	return decoded
end

return {
	getPackageDirectory = getPackageDirectory,
	createPackageLink = createPackageLink,

	encode = encode,
	decode = decode,
}
