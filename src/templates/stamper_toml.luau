-- stamper.toml template
-- written by primiti-ve on github

return [[[header]
owner = "{package_owner}"
name = "{package_name}"
description = "{package_description}"

[registry]
default = "{default_registry}"

[build]
src = "src"
excludes = []

[package]
version = "0.1.0"
type = "{package_type}"
public = {package_public}

[package.dependencies]
]]