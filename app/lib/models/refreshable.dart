import 'package:muex/muex.dart';

part 'refreshable.g.dart';

abstract class Refreshable<T> implements Model {

  factory Refreshable({
    required bool refreshing,
    List<T> items
  }) = _$Refreshable;

  bool get refreshing;
  set refreshing(bool value);

  List<T> get items;
}
