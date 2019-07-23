import 'dart:async';
import 'package:path_provider/path_provider.dart' as pathProvider;

String _directoryPath;

mixin IOMixin {
  /// Returns the [Directory.path] of the app.
  String getDirectoryPath() => _directoryPath;
}

/// The object responsible for initialzing the [directoryPath].
/// 
/// There should only be one instance of this object throughout the app,
/// preferably the root object, that will instantiate this on startup so that
/// descendant objects can use it safely.
mixin IOScopeMixin {
  /// Initializes the global [directoryPath] and returns a [Future] that
  /// completes when it's initialized.
  Future<void> initIO() {
    return pathProvider.getApplicationDocumentsDirectory().then((directory) {
      _directoryPath = directory.path;
    });
  }
}