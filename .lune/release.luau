-- stamper release script
-- written by primiti-ve on github

local fs = require("@lune/fs")
local build = require("./build")

if fs.isDir("releases") then 
    fs.removeDir("releases")
end

fs.writeDir("releases")

build("Windows", "x86_64")
build("Windows", "aarch64")

fs.removeDir("build")