'use strict';

const mongoritwo = require('../');
const run = require('./run');

run(function * () {
	// connect to a database named "examples" on localhost
	yield mongoritwo.connect('localhost/examples');

	// connected
	console.log('connected');

	// and disconnect
	yield mongoritwo.disconnect();

	// disconnected
	console.log('disconnected');
});
