-- stamper get version script
-- written by primiti-ve on github

local configuration = require("@src/configuration")
local currentVersion = configuration.currentVersion

print(`{currentVersion.full}`)