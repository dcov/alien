part of 'utils.dart';

R ifNotNull<T, R>(T t, R fn(T t), { R orElse()}) {
  return t != null ? fn(t)
       : orElse != null ? orElse()
       : null;
}
