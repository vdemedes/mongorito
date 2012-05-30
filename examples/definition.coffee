Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Post
	constructor: -> super # REQUIRED
		
Post = Mongorito.bake Post # REQUIRED, TOO