let oneMocha = require('one-mocha'),
	path = require('path'),
	SimpleOrgParser = require('../lib/simple-org-parser.js');

let sampleDir = path.resolve(__dirname, "sample"),
	orgParser = new SimpleOrgParser(sampleDir);
class SimpleOrgParserTester {
	test () {
		oneMocha(
			[
				{
					name: 'parseAll',
					method: orgParser.parseAll,
					this: orgParser,
					test: {
						assert: 'equal',
						args: [[[path.resolve(sampleDir, "test.org")], undefined]]
					}
				}
			]
		);
	}
}

module.exports = new SimpleOrgParserTester();
