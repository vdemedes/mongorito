mongolian = require 'mongolian'
async = require 'async'
inflect = require 'i'
Client = undefined

String::replaceAt = (index, char) ->
  @substr(0, index) + char + @substr(index + char.length)

`var __hasProp = {}.hasOwnProperty,
  extendsClass = function(child, parent) {
	for (var key in parent) {
		if (__hasProp.call(parent, key)) child[key] = parent[key]; 
	}
	function ctor() {
		this.constructor = child;
		for(var key in child.prototype) {
			var newKey = inflect.camelize(key);
			this[newKey.replaceAt(0, String.fromCharCode(32 + newKey.charCodeAt(0)))] = child.prototype[key];
		}
	}
	ctor.prototype = parent.prototype;
	child.prototype = new ctor;
	child.__super__ = parent.prototype;
	return child;
}`

class Mongorito
	@disconnect: ->
		do Client.close
	
	@connect: (servers = []) ->
		Client = new mongolian servers[0]
		Client.log=
			debug: ->
			info: ->
			warn: ->
			error: ->
	
	@bake: (model) ->
		extendsClass model, Model
		model::collectionName = model.collectionName = model::collectionName or inflect.pluralize model.name.toLowerCase()
		if model::scopes
			scopes = []
			for scope of model::scopes
				scopes.push scope
			
			async.forEach scopes, (scope, nextScope) ->
				model[scope] = (callback) ->
					model.find model::scopes[scope], callback
				do nextScope
			, ->
		model.model = model
		
		model


class Model
	constructor: ->
	
	fields: ->
		notFields = ['constructor', 'save', 'collectionName', 'create', 'fields', 'update', 'remove', 'beforeCreate', 'aroundCreate', 'afterCreate', 'beforeUpdate', 'aroundUpdate', 'afterUpdate', 'old', 'callMethod', 'fill', 'scopes', 'keys', 'model']
		fields = {}
		for field of @
			fields[field] = @[field] if -1 is notFields.indexOf field
		
		fields
	
	toJSON: ->
		@fields()
	
	@bakeModelsFromItems: (items, _model) ->
		models = []
		for item in items
			item._id = item._id.toString()
			model = new _model
			model.collectionName = _model.collectionName
			model.old = {}
			model.model = _model
			for field of item
				model.old[field] = model[field] = item[field]
			models.push model
		models
	
	@find: (options, callback) ->
		if typeof options is 'function'
			callback = options
			options = {}
		else
			if options.callback
				callback = options.callback
				delete options.callback
		
		that = @
		
		query = (done) ->
			fields = {}
			notFields = ['limit', 'skip', 'sort']
			for property of options
				fields[property] = options[property] if options.hasOwnProperty(property) and notFields.indexOf(property) is -1
			
			request = Client.collection(that.collectionName).find(fields)
			request = request.limit options.limit if options.limit
			request = request.skip options.skip if options.skip
			request = request.sort options.sort if options.sort
			
			request.toArray (err, items) ->
				for item in items
					item._id = item._id.toString()
				done err, items
		
		query (err, items) ->
			models = that.bakeModelsFromItems items, that.model
			callback err, models
	
	fill: (fields = {}) ->
		for key of fields
			@[key] = fields[key] if -1 < @keys.indexOf key
	
	callMethod: (method) ->
		method = @[method] or @[inflect.underscore(method)]
		do method if method
	
	save: (callback) ->
		that = @
		@old = fields = @fields()
		keys = []
		for field of fields
			keys.push field
		async.filter keys, (key, nextKey) ->
			validationMethod = that["validate#{ inflect.camelize key }"] or that["validate_#{ inflect.underscore key }"]
			if validationMethod
				validationMethod (valid) ->
					nextKey not valid
			else
				nextKey false
		, (results) ->
			return callback yes, results if results.length > 0
			
			performOperation = ->
				if fields._id
					that.update callback, yes
				else
					that.create callback, yes
			
			do performOperation
		
	create: (callback, fromSave = no) ->
		object = @fields()
		
		@callMethod 'beforeCreate'
		@callMethod 'aroundCreate'
		that = @
		
		Client.collection(@collectionName).insert object, (err, result) ->
			result._id = result._id.toString()
			that._id = result._id
			that.callMethod 'aroundCreate'
			that.callMethod 'afterCreate'
			callback err, result if callback
		
	update: (callback, fromSave = no) ->
		object = @fields()
		_id = new mongolian.ObjectId object._id
		delete object._id
		
		@callMethod 'beforeUpdate'
		@callMethod 'aroundUpdate'
		that = @
		
		Client.collection(@collectionName).update { _id: _id }, object, (err, rowsUpdated) ->
			that.callMethod 'aroundUpdate'
			that.callMethod 'afterUpdate'
			callback err, rowsUpdated if callback
	
	remove: (callback) ->
		object = @fields()
		
		_id = new mongolian.ObjectId object._id
		
		@callMethod 'beforeRemove'
		@callMethod 'aroundRemove'
		that = @
		query = ->
			Client.collection(that.collectionName).remove _id: _id, (err) ->
				that.callMethod 'aroundRemove'
				that.callMethod 'afterRemove'
				callback err if callback
		do query

module.exports=
	connect: Mongorito.connect
	disconnect: Mongorito.disconnect
	bake: Mongorito.bake