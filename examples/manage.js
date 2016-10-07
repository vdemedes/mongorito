'use strict';

const mongoritwo = require('../');
const run = require('./run');

const Model = mongoritwo.Model;

class Post extends Model {

}

run(function * () {
	yield mongoritwo.connect('localhost/examples');

	// create
	let post = new Post({
		title: 'Great title'
	});

	yield post.save();

	// post created
	console.log('Post created with ID: ', post.get('_id'));
	console.log(post.get());

	// update
	post.set('title', 'New title');
	yield post.save();

	// post updated
	console.log('Post got a new title: ', post.get('title'));

	// remove
	yield post.remove();

	// post removed
	console.log('Post removed');

	// remove all posts with title = "Wow"
	yield Post.remove({ title: 'Wow' });

	// done
	console.log('Removed all posts matching a criteria');

	yield mongoritwo.disconnect();
});
