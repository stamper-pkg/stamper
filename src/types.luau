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

	package: {
		version: string,
		public: boolean,

		dependencies: { [string]: packageDependency },
	},

	flags: { [string]: true },
}

return nil
