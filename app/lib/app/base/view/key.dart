import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class GlobalValueKey<V, S extends State<StatefulWidget>> extends GlobalKey<S> {

  const GlobalValueKey(this.value) : super.constructor();

  final V value;

  @override
  bool operator==(dynamic other) {
    if (other.runtimeType != this.runtimeType)
      return false;
    final GlobalValueKey<V, S> typedOther = other;
    return identical(value, typedOther.value);
  }

  @override
  int get hashCode => identityHashCode(value);

  @override
  String toString() {
    String selfType = runtimeType.toString();
    const String suffix = '<State<StatefulWidget>>';
    if (selfType.endsWith(suffix)) {
      selfType = selfType.substring(0, selfType.length - suffix.length);
    }
    return '[$selfType ${describeIdentity(value)}]';
  }
}