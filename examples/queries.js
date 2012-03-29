var Mongorito, Post;

Mongorito = require('../lib/mongorito');

Mongorito.connect(['mongo://127.0.0.1:27017/databaseName']);

Post = (function() {

  function Post() {
    Post.__super__.constructor.call(this, 'posts');
  }

  return Post;

})();

Post = Mongorito.bake(Post);

Post.find(function(err, posts) {
  var post, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = posts.length; _i < _len; _i++) {
    post = posts[_i];
    _results.push(console.log(post.title));
  }
  return _results;
});

Post.find({
  title: 'Nice title!'
}, function(err, posts) {});

Post.find({
  limit: 5
}, function(err, posts) {});

Post.find({
  author: 'Drew',
  limit: 5
}, function(err, posts) {});

Post.find({
  limit: 5,
  skip: 2
}, function(err, posts) {});

Post.find({
  author: 'Drew',
  limit: 5,
  skip: 2
}, function(err, posts) {});

Post.find({
  sort: {
    _id: -1
  }
}, function(err, posts) {});

Post.find({
  limit: 5,
  sort: {
    _id: -1
  }
}, function(err, posts) {});

Post.find({
  limit: 5,
  skip: 2,
  sort: {
    _id: -1
  }
}, function(err, posts) {});

Post.find({
  limit: 5,
  skip: 2,
  author: 'Drew',
  sort: {
    _id: -1
  }
}, function(err, posts) {});
