import 'package:reddit/reddit.dart';

RedditClient _client;

RedditInteractor _interactor;

mixin RedditMixin {
  /// The global [RedditClient] which is needed to instantiate [RedditInteractor]'s.
  /// This should only be set once at the start of the app.
  RedditClient getClient() => _client;

  /// The current global [RedditInteractor] which can be used to interact with
  /// Reddit endpoints. This will change throughout the life of the app.
  RedditInteractor getInteractor() => _interactor;
}

/// The object responsible for instantiating both the [client] and [reddit]
/// values.
/// 
/// There should only be one instance of this object throughout the app,
/// preferably the root object, that will instantiate this on startup so that
/// descendant objects can use it safely.
mixin RedditScopeMixin {
  
  /// Sets the global [client] value.
  void setClient(RedditClient value) {
    _client = value;
  }
  
  /// Sets the global [reddit] value.
  void setInteractor(RedditInteractor value) {
    _interactor = value;
  }
}