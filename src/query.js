'use strict';

const isObject = require('is-plain-obj');
const mquery = require('mquery');

class Query extends mquery {

	findById(id) {
		this.where('_id', id);

		return this.model.dbCollection()
			.then(collection => {
				return new Promise((resolve, reject) => {
					this.collection(collection).findOne((err, doc) => {
						if (err) {
							reject(err);
							return;
						}

						if (!doc) {
							resolve(null);
							return;
						}

						const model = new this.model(doc); // eslint-disable-line babel/new-cap
						resolve(model);
					});
				});
			});
	}

	include(field, value = 1) {
		if (Array.isArray(field)) {
			field.forEach(field => this.include(field));
			return this;
		}

		let select = {};

		if (isObject(field)) {
			select = field;
		}

		select[field] = value;

		this.select(select);

		return this;
	}

	exclude(field, value = 0) {
		if (Array.isArray(field)) {
			field.forEach(field => this.exclude(field));
			return this;
		}

		let select = {};

		if (isObject(field)) {
			select = field;
		}

		select[field] = value;

		this.select(select);

		return this;
	}

	sort(field, value = 'desc') {
		if (Array.isArray(field)) {
			field.forEach(field => this.sort(field));
			return this;
		}

		let sort = {};

		if (isObject(field)) {
			sort = field;
		}

		sort[field] = value;

		super.sort(sort);

		return this;
	}

	search(query) {
		return this.where({
			'$text': {
				'$search': query
			}
		});
	}

	then(success, reject) {
		return this._beforeHooks()
			.then(() => this.model.dbCollection())
			.then(collection => {
				this.collection(collection);
				return super.then();
			})
			.then(docs => this._afterHooks(docs))
			.then(success, reject);
	}

	_beforeHooks() {
		if (this.op === 'find' || this.op === 'findOne') {
			return this.model.hooks.run('before', 'find', [], this);
		}
		return Promise.resolve();
	}

	_afterHooks(data) {
		if (this.op === 'findOne') {
			return this.model.hooks.run('after', 'find', [[data]], this)
				.then(docs => docs[0]);
		}
		if (this.op === 'find') {
			return this.model.hooks.run('after', 'find', [data], this);
		}
		return data;
	}
}

module.exports = Query;
