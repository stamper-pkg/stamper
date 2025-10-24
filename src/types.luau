-- stamper types
-- written by primiti-ve on github

export type packageDependency = {
	owner: string,
	name: string,
	version: string,
}

export type packageData = {
	header: {
		owner: string,
		name: string,
		description: string,
	},

	registry: {
		default: string,
	},

	build: {
		src: string,
		excludes: { string },
	},

	package: {
		version: string,
		type: string,
		public: boolean,

		dependencies: { [string]: packageDependency },
	},

	flags: { [string]: true },
}

export type installData = {
	alias: string,
	name: string,

	content: string,
	target: string,

	flags: { [string]: true },
}

return nil
