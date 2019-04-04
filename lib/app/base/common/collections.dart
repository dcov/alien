
class _DelegatingIterable<E> implements Iterable<E> {

  const _DelegatingIterable(this._source);

  final Iterable<E> _source;

  @override
  Iterator<E> get iterator => _source.iterator;

  @override
  Iterable<R> cast<R>() => _source.cast<R>();

  @override
  Iterable<E> followedBy(Iterable<E> other) => _source.followedBy(other);

  @override
  Iterable<T> map<T>(T f(E e)) => _source.map<T>(f);

  @override
  Iterable<E> where(bool test(E element)) => _source.where(test);

  @override
  Iterable<T> whereType<T>() => _source.whereType<T>();

  @override
  Iterable<T> expand<T>(Iterable<T> f(E element)) => _source.expand<T>(f);

  @override
  bool contains(Object element) => _source.contains(element);

  @override
  void forEach(void f(E element)) => _source.forEach(f);

  @override
  E reduce(E combine(E value, E element)) => _source.reduce(combine);

  @override
  T fold<T>(T initialValue, T combine(T previousValue, E element)) => _source.fold<T>(initialValue, combine);

  @override
  bool every(bool test(E element)) => _source.every(test);

  @override
  String join([String separator = ""]) => _source.join(separator);

  @override
  bool any(bool test(E element)) => _source.any(test);

  @override
  List<E> toList({bool growable: true}) => _source.toList(growable: growable);

  @override
  Set<E> toSet() => _source.toSet();

  @override
  int get length => _source.length;

  @override
  bool get isEmpty => _source.isEmpty;

  @override
  bool get isNotEmpty => _source.isNotEmpty;

  @override
  Iterable<E> take(int count) => _source.take(count);

  @override
  Iterable<E> takeWhile(bool test(E value)) => _source.takeWhile(test);

  @override
  Iterable<E> skip(int count) => _source.skip(count);

  @override
  Iterable<E> skipWhile(bool test(E value)) => _source.skipWhile(test);

  @override
  E get first => _source.first;

  @override
  E get last => _source.last;

  @override
  E get single => _source.single;

  @override
  E firstWhere(bool test(E element), {E orElse()}) => _source.firstWhere(test, orElse: orElse);

  @override
  E lastWhere(bool test(E element), {E orElse()}) => _source.lastWhere(test, orElse: orElse);

  @override
  E singleWhere(bool test(E element), {E orElse()}) => _source.singleWhere(test, orElse: orElse);

  @override
  E elementAt(int index) => _source.elementAt(index);

  @override
  String toString() => _source.toString();

  @override
  int get hashCode => _source.hashCode;

  @override
  bool operator==(other) => _source == other;
}

class ImmutableList<E> extends _DelegatingIterable<E> {

  const ImmutableList(List<E> source) : super(source);

  @override
  List<E> get _source => super._source;

  E operator [](int index) => _source[index];

  Iterable<E> get reversed => _source.reversed;

  int indexOf(E element, [int start = 0]) => _source.indexOf(element, start);

  int indexWhere(bool test(E element), [int start = 0]) => _source.indexWhere(test, start);

  int lastIndexWhere(bool test(E element), [int start]) => _source.lastIndexWhere(test, start);

  int lastIndexOf(E element, [int start]) => _source.lastIndexOf(element, start);

  List<E> operator +(List<E> other) => _source + other;

  List<E> sublist(int start, [int end]) => _source.sublist(start, end);

  Iterable<E> getRange(int start, int end) => _source.getRange(start, end);

  Map<int, E> asMap() => _source.asMap();
}

class ImmutableSet<E> extends _DelegatingIterable<E> {

  const ImmutableSet(Set<E> source) : super(source);

  @override
  Set<E> get _source => super._source;

  E lookup(Object object) => _source.lookup(object);

  bool containsAll(Iterable<Object> other) => _source.containsAll(other);

  Set<E> intersection(Set<Object> other) => _source.intersection(other);

  Set<E> union(Set<E> other) => _source.union(other);

  Set<E> difference(Set<Object> other) => _source.difference(other);
}

class ImmutableMap<K, V> {

  ImmutableMap(this._source);

  final Map<K, V> _source;

  Map<RK, RV> cast<RK, RV>() => _source.cast<RK, RV>();

  bool containsValue(Object value) => _source.containsValue(value);

  bool containsKey(Object key) => _source.containsKey(key);

  V operator [](Object key) => _source[key];

  Iterable<MapEntry<K, V>> get entries => _source.entries;

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> f(K key, V value)) => _source.map<K2, V2>(f);

  void forEach(void f(K key, V value)) => _source.forEach(f);

  Iterable<K> get keys => _source.keys;

  Iterable<V> get values => _source.values;

  int get length => _source.length;

  bool get isEmpty => _source.isEmpty;

  bool get isNotEmpty => _source.isNotEmpty;
}