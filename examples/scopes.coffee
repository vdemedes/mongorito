Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Post
	keys: ['author', 'content', 'title']
	scopes:
		byDrew: author: 'Drew'
		one: limit: 1

Post = Mongorito.bake Post

Post.one (err, posts) ->
	posts.length is 1

Post.byDrew (err, posts) ->
	# posts with author=Drew