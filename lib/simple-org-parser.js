let fs = require('fs'),
	deasync = require('deasync'),
	moment = require('moment'),
	ProjectDir = require('project-dir'),
	org = require('org-mode-parser');

class SimpleOrgParser {
	constructor (basedir) {
		this.projectDir = basedir;
	}

	parseAll (files) {
		let self = this,
			count = 0,
			allData = {};
		console.log(this.projectDir.parse(files[0]));
		files.forEach(file => {
			count++;
			self.parse(file, result => {
				allData[file] = result;
				count--;
			});
		});
		while (count > 0) {
			deasync.sleep(10);
		}
		console.log(allData);
	}

	parse (file, callback) {
		let self = this;
		org.makelist(file, nl => {
			let props = self.collectNode(nl, 'properties');
			let tags = self.collectNode(nl, 'tags');
			callback({properties: props, tags: tags});
		});
	}

	collectNode (nodeList, propName) {
		return nodeList.map(e => {
			let data = e[propName];
			if (data != null) {
				return {
					key: e.key,
					data: data
				};
			}
			return null;
		}).filter(e => Object.keys(e.data).length > 0);
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
