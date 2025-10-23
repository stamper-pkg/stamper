-- package utils
-- written by primiti-ve on github

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local compressor = require("../compressor")
local encodeFormat: serde.EncodeDecodeFormat = "json"

function getPackageDirectory()
	local cwd = process.cwd
	local path = `{cwd}stamper_packages`

	if not fs.isDir(path) then
		fs.writeDir(path)
	end

	return path, fs.readDir(path)
end

function createPackageLink(path: string, alias: string, data: string)
    if not path or not data then 
        return
    end

	local packagePath = `{path}/{alias}.luau`

	if fs.isFile(packagePath) then
		fs.removeFile(packagePath)
	end

	fs.writeFile(packagePath, data)
end

function encode(data: string)
    if not data then 
        return nil
    end

	local parsed = data

	parsed = serde.encode(encodeFormat, parsed)
	parsed = compressor.compress(parsed)

	return parsed
end

function decode(data: string)
    if not data then 
        return nil
    end

	local parsed = data

	parsed = compressor.decompress(parsed)
	parsed = serde.decode(encodeFormat, parsed)

	return parsed
end

return {
	getPackageDirectory = getPackageDirectory,
	createPackageLink = createPackageLink,

	encode = encode,
	decode = decode,
}
