import 'package:flutter/foundation.dart';

typedef ModelVisitor = void Function(Model child);

abstract class Model extends ChangeNotifier {

  @protected
  @mustCallSuper
  void visitChildren(ModelVisitor visitor) { }

  @override
  @protected 
  // ignore: must_call_super
  bool dispose() => disposeChildren();

  @protected
  @mustCallSuper
  bool disposeChildren() {
    bool disposed = true;
    visitChildren((Model child) {
      disposed = disposeChild(child) && disposed;
    });
    return disposed;
  }

  @protected
  @mustCallSuper
  bool disposeChild(Model child) {
    return child.dispose();
  }
}

mixin UndisposedStoreMixin on Model {

  final Set<Model> _undisposed = Set<Model>();

  @override
  bool disposeChild(Model child) {
    final bool result = super.disposeChild(child);
    if (!result)
      _undisposed.add(child);
    return result;
  }

  void absorbUndisposed(UndisposedStoreMixin other) {
    _undisposed.addAll(other._undisposed);
    other._undisposed.clear();
  }

  @protected
  @mustCallSuper
  Model takeUndisposedIf(bool test(Model child)) {
    Model result;
    for (final Model child in _undisposed) {
      if (test(child)) {
        result = child;
        break;
      }
    }
    if (result != null)
      _undisposed.remove(result);
    return result;
  }

  @protected
  @mustCallSuper
  T takeUndisposedOfType<T extends Model>() {
    return takeUndisposedIf((Model child) => child is T);
  }

  @protected
  @mustCallSuper
  T takeUndisposedOfTypeIf<T extends Model>(bool test(T child)) {
    return takeUndisposedIf((Model child) => child is T && test(child));
  }
}