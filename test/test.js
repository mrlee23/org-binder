const path = require('path');
const testList = [
	"simple-org-parser.js",
];
class Test {
	all () {
		this.some(testList);
	}
	some (names) {
		names.forEach(name => {
			describe(`${name}`, function () {
				let tester = require(path.resolve(__dirname, name));
				tester.test();
			});
		});
	}
	testing (checkList) {
		checkList.forEach(func => {
			describe(`#.${func}()`, function () {
				let args = func.args;
				func.forEach(args => {
					
				});
			});
		});
	}
}

const test = new Test();
test.all();
