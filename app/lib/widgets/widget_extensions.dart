import 'package:flutter/widgets.dart';

extension NavigatorExtensions on BuildContext {

  Future<T> push<T>(Route<T> route) => Navigator.push(this, route);

  bool pop<T>([T result]) => Navigator.pop(this, result);
}

