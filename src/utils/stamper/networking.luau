-- networking utils
-- written by primiti-ve on github

local net = require("@lune/net")
local configuration = require("../../configuration")

local types = require("../../types")
local spin = require("../../utils/spin")

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
		print(`[stamper] got package {data.header.owner}/{data.header.name}!`)

		if data.flags.verbose then
			print(`[stamper verbose] {response.body}`)
		end

		return response.body
	else
		print(`[stamper] request failed: {response.statusCode}`)

		return nil
	end
end

function new(data: types.packageData)
	print(
		`[stamper] publishing package {data.header.owner}/{data.header.name}, version {data.package.version}! please wait...`
	)

	print()

	local stop = spin.create(spin.animations.material)
	local response = net.request({
		method = "POST",
		url = `{configuration.baseUrl}/packages/new`,

		query = {
			owner = data.header.owner,
			name = data.header.name,
			version = data.package.version,
		},
	})

	stop()

	if response.ok then
		if data.flags.verbose then
			print(`[stamper verbose] published package!`)
			print(`[stamper verbose] {response.body}`)
		end

		return response.body
	else
		print(`[stamper] request failed: {response.statusCode}`)

		return nil
	end
end

return {
	get = get,
	new = new,
}
