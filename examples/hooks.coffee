Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Post
	
	beforeCreate: -> # before creating post
		
	aroundCreate: -> # before and after creating post
	
	afterCreate: -> # after creating post
	
	beforeUpdate: -> # before updating post
	
	aroundUpdate: -> # before and after updating post
	
	afterUpdate: -> # after updating post

Post = Mongorito.bake Post