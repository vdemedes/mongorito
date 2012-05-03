Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Post
	keys: ['title', 'content']
		
Post = Mongorito.bake Post

# Creating new post
post = new Post
post.title = 'Title of the post'
post.content = 'Content of the post'
post.save (err, results) ->
	# results will be populated with invalid fields, if validators will be defined

# Updating post

post.title = 'Changed title of the previously saved post'
post.save (err, results) ->
	# results will be populated with invalid fields, if validators will be defined

# Removing post

post.remove (err) ->