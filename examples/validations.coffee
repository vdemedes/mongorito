Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/databaseName']

class Tweet
	keys: ['body']
	
	validateBody: (callback) -> # you should pass false, if invalid and true, if valid
		if @body.length >= 140
			callback false
		else
			callback true
		
Tweet = Mongorito.bake Tweet

tweet = new Tweet
tweet.body = 'I want to be super-super-super-super long! Reallly, reallly, long!!!! In fact, I am VEEERY long! You\'ve never seen such a looooooong tweeeeeet!'
tweet.save (err, results) ->
	# results will be ['body'], because body field did not pass validation