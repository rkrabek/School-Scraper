var searches = ['/schools/private-schools/vision-afrika-primary-school.html',
		'/tutors/hartenbos-eden-christelike-akademie.html',
        '/schools/private-schools/west-coast-music-academy.html',
        '/schools/private-schools/edu-excellence-private-remedial-school-cape-town.html'];
var schoolArray = [[],[]]
var page = require('webpage').create();
function follow(search, callback) {
    page.open('https://www.schoolguide.co.za' + search, function (status) {
    	// console.log('https://www.schoolguide.co.za/schools/private-schools/' + search)
        if (status === 'fail') {
            console.log(search + ': ?');
        } else {
        	console.log("getting school info");
        	var name = page.evaluate(function () {
                return document.querySelector('article div div h1 span').innerText;
            });
            console.log(name);
        	var school = page.evaluate(function () {
                return document.querySelector('title').innerText;
            });
            var data = page.evaluate(function () {
                return document.querySelector('tbody tr td span a').href;
            });
            console.log(search + ' email: ' + data);
            schoolArray[0].push(search + ' school: ' + school);
            schoolArray[1].push(search + ' email: ' + data);
            // console.log('success')
        }
        page.close();
        callback.apply();
    });
}

function process() {
    if (searches.length > 0) {
        var search = searches[0];
        searches.splice(0, 1);
        follow(search, process);
    } else {
    	var fs = require('fs');

		var path = 'output.csv';
		var content = schoolArray;
		fs.write(path, content, 'w');
        phantom.exit();
    }
}

process();