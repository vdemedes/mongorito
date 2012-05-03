Mongorito = require '../lib/mongorito'

Mongorito.connect ['mongo://127.0.0.1:27017/mongorito']

require 'should'
async = require 'async'

class Post
	keys: ['author', 'title']
	scopes:
		one: limit: 1
		latest: title: 'Just created'

Post = Mongorito.bake Post

describe 'Mongorito', ->
	describe 'creating new record', ->
		it 'should create new record in "posts" collection', (done) ->
			post = new Post
			post.title = 'Very nice post!'
			post.author = 'Vadim'
			post.save ->
				Post.find (err, posts) ->
					posts.length.should.equal 1
					do done
		
		it 'should mass-asign post info', (done) ->
			post = new Post
			post.fill title: 'Very nice post!', author: 'Vadim', admin: yes
			post.title.should.equal('Very nice post!') and post.author.should.equal('Vadim') and not post.admin
			do done
	
	describe 'editing record', ->
		it 'should save edited version of the post', (done) ->
			Post.find (err, posts) ->
				post = posts[0]
				post.title = 'Edited title!'
				post.save ->
					do done
		
		it 'should have 2 versions of the document', (done) ->
			Post.find (err, posts) ->
				post = posts[0]
				post.title = 'Totally different title!'
				post.old.title.should.equal('Edited title!') and post.title.should.equal 'Totally different title!'
				do done
	
	describe 'getting records', ->
		it 'should fetch just edited post', (done) ->
			Post.find (err, posts) ->
				posts[0].title.should.equal 'Edited title!'
				do done
		
		it 'should fetch post with regex', (done) ->
			Post.find title: /^Edit/i, (err, posts) ->
				posts.length.should.equal 1
				do done
		
		it 'should fetch only one post', (done) ->
			Post.find limit: 1, (err, posts) ->
				posts.length.should.equal 1
				do done
			
		it 'should fetch post by title', (done) ->
			Post.find title: 'Edited title!', (err, posts) ->
				posts.length.should.equal 1
				do done
		
		it 'should create another post and fetch only one', (done) ->
			post = new Post
			post.title = 'Just created'
			post.author = 'Vadim'
			post.save ->
				Post.find limit: 1, skip: 1, (err, posts) ->
					posts.length.should.equal 1
					do done
		
		it 'should fetch posts, ordering by the time of creation', (done) ->
			Post.find sort: { _id: -1 }, (err, posts) ->
				posts[0].title is 'Just created' and posts.length.should.equal 2
				do done
	
	describe 'testing scopes', ->
		it 'should fetch only 1 post', (done) ->
			Post.one (err, posts) ->
				posts.length.should.equal 1
				do done
		
		it 'should fetch only latest posts', (done) ->
			Post.latest (err, posts) ->
				posts.length.should.equal 1
				do done
	
	describe 'deleting records', ->
		it 'should remove all posts', (done) ->
			Post.find (err, posts) ->
				async.forEach posts, (post, nextPost) ->
					post.remove ->
						do nextPost
				, ->
					Post.find (err, posts) ->
						posts.length.should.equal 0
						do done