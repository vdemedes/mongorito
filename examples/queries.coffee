Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Post
	keys: ['title', 'author', 'content']
		
Post = Mongorito.bake Post

Post.find (err, posts) ->
	for post in posts
		console.log post.title # post is a Post model, so you can perform all usual operations

Post.find title: 'Nice title!', (err, posts) ->

Post.find limit: 5, (err, posts) -> # getting only first 5 posts

Post.find author: 'Drew', limit: 5, (err, posts) -> # getting only first 5 posts with author = Drew

Post.find limit: 5, skip: 2, (err, posts) -> # getting only 5 posts, skipping first 2

Post.find author: 'Drew', limit: 5, skip: 2, (err, posts) -> # getting only 5 posts, skipping first 2, with author = Drew

Post.find sort: _id: -1, (err, posts) -> # getting posts, sorted by _id

Post.find limit: 5, sort: _id: -1, (err, posts) -> # getting first 5 posts, sorted by _id

Post.find limit: 5, skip: 2, sort: _id: -1, (err, posts) -> # getting 5 posts, skipping first 2, sorted by _id

Post.find limit: 5, skip: 2, author: 'Drew', sort: _id: -1, (err, posts) -> # getting 5 posts, skipping first 2, sorted by _id, with author = Drew