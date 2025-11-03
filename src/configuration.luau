-- stamper configuration file
-- written by primiti-ve on github

local configuration = {
	currentVersion = { major = "0", minor = "1", patch = "2" },
	baseUrl = "https://stamper-registry.primiti-ve.workers.dev",
}

configuration.currentVersion.full = string.format(
	"%s.%s.%s",
	configuration.currentVersion.major,
	configuration.currentVersion.minor,
	configuration.currentVersion.patch
)

return configuration
