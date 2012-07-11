mongolian = require 'mongolian'
async = require 'async'
inflect = require('i')()
Client = undefined

String::replaceAt = (index, char) ->
  @substr(0, index) + char + @substr(index + char.length)

hasProp = {}.hasOwnProperty
extendClass = (child, parent) ->
	for key of parent
		child[key] = parent[key] if hasProp.call parent, key
	
	ctor = ->
		@constructor = child
		for key of child::
			newKey = inflect.camelize key
			@[newKey.replaceAt(0, String.fromCharCode(32 + newKey.charCodeAt(0)))] = child::[key]
		
		undefined
	
	ctor:: = parent::
	child:: = new ctor
	child.__super__ = parent::
	child

class Mongorito
	@disconnect: ->
		do Client.server.close
	
	@connect: (servers = []) ->
		Client = new mongolian servers[0], log:
			debug: ->
			info: ->
			warn: ->
			error: ->
	
	@bake: (model) ->
		extendClass model, Model
		model::collectionName = model.collectionName = model::collectionName or inflect.pluralize model.name.toLowerCase()
		if model::scopes
			Object.keys(model::scopes).forEach (scope) ->
				model[scope] = (callback) ->
					model.find model::scopes[scope], callback
		
		model::keys.forEach (key) ->
			model::__defineGetter__ key, ->
				@get key

			model::__defineSetter__ key, (value) ->
				@set key, value
		
		model::__defineGetter__ '_id', ->
			@get '_id'
		
		model::__defineSetter__ '_id', (value) ->
			@set '_id', value.toString()
		
		model::model = model.model = model
		
		model


class Model
	fields: {}
	old: {}
	
	get: (key) ->
		@fields[key]
	
	set: (key, value) ->
		@old[key] = @fields[key] if @fields[key]
		@fields[key] = value
	
	constructor: ->
		@fields = @old = {}
	
	toJSON: ->
		@fields
	
	@bakeModelsFromItems: (items) ->
		models = []
		for item in items
			item._id = item._id.toString()
			model = new @model
			model.collectionName = @model.collectionName
			model.old = {}
			model.model = @model
			for field of item
				model[field] = item[field]
			models.push model
		models
	
	@extractFields: (options) ->
		fields = {}
		notFields = ['limit', 'skip', 'sort']
		for property of options
			fields[property] = options[property] if options.hasOwnProperty(property) and notFields.indexOf(property) is -1
		
		fields
	
	@find: (options, callback) ->
		if typeof options is 'function'
			callback = options
			options = {}
		else
			if options.callback
				callback = options.callback
				delete options.callback
		
		return @findOne(options, callback) if options._id
		
		query = Client.collection(@collectionName).find @extractFields(options)
		query = query.sort options.sort if options.sort
		query = query.skip options.skip if options.skip
		query = query.limit options.limit if options.limit
		
		query.toArray (err, items) =>
			callback err, @bakeModelsFromItems items
	
	@findOne: (options, callback) ->
		_id = new mongolian.ObjectId options._id
		
		Client.collection(@collectionName).find(_id: _id).toArray (err, items) =>
			callback err, @bakeModelsFromItems(items)[0]
	
	updateAttributes: (fields = {}) ->
		for key of fields
			@[key] = fields[key] if -1 < @keys.indexOf key
	
	update_attributes: -> @updateAttributes.apply @, arguments
	
	callMethod: (method) ->
		method = @[method] or @[inflect.underscore(method)]
		method.call @ if method
	
	save: (callback) ->
		async.filter @keys, (key, nextKey) =>
			validationMethod = @["validate#{ inflect.camelize key }"] or @["validate_#{ inflect.underscore key }"]
			if validationMethod
				validationMethod.call @, (valid) ->
					nextKey not valid
			else
				nextKey false
		, (results) =>
			return callback(yes, results) if results.length > 0
			
			if @fields._id then @update(callback) else @create(callback)
		
	create: (callback) ->
		@callMethod 'beforeCreate'
		@callMethod 'aroundCreate'
		
		Client.collection(@collectionName).insert @fields, (err, result) =>
			result._id = result._id.toString()
			@fields._id = result._id
			@callMethod 'aroundCreate'
			@callMethod 'afterCreate'
			callback err, result if callback
		
	update: (callback) ->
		fields = {}
		for key of @fields
			fields[key] = @fields[key]
		
		_id = new mongolian.ObjectId fields._id
		delete fields._id
		
		@callMethod 'beforeUpdate'
		@callMethod 'aroundUpdate'
		
		Client.collection(@collectionName).update { _id: _id }, fields, (err, rowsUpdated) =>
			@callMethod 'aroundUpdate'
			@callMethod 'afterUpdate'
			callback err, rowsUpdated if callback
	
	remove: (callback) ->
		_id = new mongolian.ObjectId @fields._id
		
		@callMethod 'beforeRemove'
		@callMethod 'aroundRemove'
		
		Client.collection(@collectionName).remove _id: _id, (err) =>
			@callMethod 'aroundRemove'
			@callMethod 'afterRemove'
			callback err if callback
	
	@remove: (callback) ->
		Client.collection(@collectionName).remove {}, (err) ->
			callback err if callback

module.exports=
	connect: Mongorito.connect
	disconnect: Mongorito.disconnect
	bake: Mongorito.bake
