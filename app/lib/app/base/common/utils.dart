
/// Iterates over [iter] until the function [f] returns a non-null value.
dynamic iterateUntilValue<T>(Iterable<T> iter, dynamic f(T t)) {
  for (final T t in iter) {
    final result = f(t);
    if (result != null)
      return result;
  }
}

bool iterateUntil<T>(Iterable<T> iter, bool test(T t)) {
  for (final T t in iter) {
    if (test(t))
      return true;
  }
  return false;
}