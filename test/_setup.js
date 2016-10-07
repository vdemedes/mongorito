'use strict';

/**
 * Dependencies
 */

const mongoritwo = require('../');

const Comment = require('./fixtures/models/comment');
const Account = require('./fixtures/models/account');
const Post = require('./fixtures/models/post');
const Task = require('./fixtures/models/task');


/**
 * Setup hooks
 */

function setup (test) {
	test.before(() => mongoritwo.connect((process.env.MONGO_URL ? process.env.MONGO_URL : 'localhost/mongoritwo_test')));

	test.beforeEach(() => Account.remove());
	test.beforeEach(() => Comment.remove());
	test.beforeEach(() => Post.remove());
	test.beforeEach(() => Task.remove());

	test.after(() => mongoritwo.disconnect());
}


/**
 * Expose fn
 */

module.exports = setup;
