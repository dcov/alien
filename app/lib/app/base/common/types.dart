import 'package:meta/meta.dart';

export 'package:quiver/core.dart' show Optional;

typedef ValueMapper<K, V> = V Function(K key);

typedef ValueCallback<V> = void Function(V value);

/// An [Optional]-like object that has three possible states:
/// 
/// - [isPresent] when it has a value.
/// - [isAbsent] when it does not have value.
/// - [isDelayed] when it's unknown whether it has a value or not.
@immutable
class Delayable<T> {

  /// Creates a [Delayable] where [isPresent] is true and both [isDelayed]
  /// and [isPresent] are false. A client can use the value safely.
  factory Delayable.of(T value) {
    if (value == null)
      throw ArgumentError('DelayedOptional.of called with a null value.');
    return Delayable._(value, false);
  }

  /// Creates a [Delayable] where [isAbsent] and [isPresent] are both
  /// false, and [isDelayed] is true. A client of this instance can check
  /// back later to see if this gets replaced with an instance where [isPresent]
  /// is true.
  factory Delayable.delayed() => const Delayable._(null, true);

  /// Creates a [Delayable] where [isAbsent] is true and both [isDelayed]
  /// and [isPresent] are false. A client can not use this value.
  factory Delayable.absent() => const Delayable._(null, false);

  /// Creates either a [Delayable.of] it the value is not null, or a
  /// [Delayable.delayed] if it is.
  factory Delayable.fromDelayable(T value) {
    if (value == null)
      return Delayable.delayed();
    return Delayable.of(value);
  }

  /// Creates either a [Delayable.of] if the value is not null, or a
  /// [Delayable.absent] if it is.
  factory Delayable.fromNullable(T value) {
    if (value == null)
      return Delayable.absent();
    return Delayable.of(value);
  }

  const Delayable._(this._value, this.isDelayed);

  T get value {
    if (_value == null)
      throw StateError('Tried to get absent value of DelayedOptional.');
    return _value;
  }

  final T _value;

  bool get isPresent => _value != null;

  bool get isAbsent => _value == null && !isDelayed;

  /// Whether the availability of this value is still being determined.
  final bool isDelayed;

  void check({
    void onPresent(T value),
    void onDelayed(),
    void onAbsent()
  }) {
    if (isPresent)
      return onPresent(_value);
    else if (isDelayed)
      return onDelayed();
    else
      return onAbsent();
  }
}