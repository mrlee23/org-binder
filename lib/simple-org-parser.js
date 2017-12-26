let fs = require('fs'),
	deasync = require('deasync'),
	moment = require('moment'),
	ProjectDir = require('project-dir'),
	org = require('org-mode-parser');

class SimpleOrgParser {
	constructor (basedir) {
		this.projectDir = basedir;
	}

	collectFiles (regexp = /\.org$/) {
	}

	collectProperties (files) {
		let count = 0,
			properties = {};
		files.forEach(file => {
			count ++;
			org.makelist(file, nl => {
				let result = nl.map(e => e.properties).filter(e => Object.keys(e).length > 0);
				console.log(this.projectDir.parse(file));
				count --;
			});
		});
	}

	set projectDir (_path) {
		let projectDir;
		try {
			projectDir = new ProjectDir(_path, [".git", "Makefile"]);
		} catch (e) {
			e.message = e.message + `\nError occured generating ProjectDir.\nThe path(${_path}) cannot be a base directory.`;
		}
		this._projectDir = projectDir;
	}
	get projectDir () { return this._projectDir; }

}

module.exports = SimpleOrgParser;
