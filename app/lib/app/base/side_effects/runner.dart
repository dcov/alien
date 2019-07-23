import 'dart:async';

import 'package:isolate/isolate.dart';

/// The global [LoadBalancer] which can be used to run computationally
/// expensive tasks on a separate isolate.
LoadBalancer _runner;

mixin RunnerMixin {
  /// Calls the [function] with the given [argument] on a separate isolate using
  /// the global [LoadBalancer].
  Future<R> run<R, P>(
    FutureOr<R> function(P argument),
    P argument, {
    Duration timeout,
    FutureOr<R> onTimeout(),
    int load = 100
  }) {
    return _runner.run(
      function,
      argument,
      timeout: timeout,
      onTimeout: onTimeout,
      load: load
    );
  }
}

/// The object responsible for instantiating the [runner].
/// 
/// There should only be one instance of this object throughout the app,
/// preferably the root object, that will instantiate this on startup so that
/// descendant objects can use it safely.
mixin RunnerScopeMixin {
  /// Initializes the global [runner] and returns a [Future] that completes
  /// once it's been initialized.
  Future<void> initRunner() {
    return LoadBalancer.create(5, IsolateRunner.spawn).then((balancer) {
      _runner = balancer;
    });
  }
}