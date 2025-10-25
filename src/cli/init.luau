-- stamper commands list
-- written by primiti-ve on github

local commands = {
    new = require("@self/new"),
    add = require("@self/add"),
    install = require("@self/install"),
    publish = require("@self/publish"),
    none = require("@self/none"),
}

require("@src/commands").commands = commands

return commands